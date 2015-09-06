require 'mechanize'
require 'resolv'

require "dozens_jp_cli/version"

## TODO: DozensJP DNS round robin is supported, but this script  dose not support dns round robin 
class Dozens
    attr_accessor :ua
    API_BASE_URI = "http://dozens.jp/api"

    def initialize(user,auth_key)
        @user = user
        @auth_key = auth_key
        @ua = Mechanize.new
    end
    def get(uri,header=nil,params=[])
        self.request(:get,uri,header,params)
    end
    def post(uri,header=nil,params=[])
        self.request(:post,uri,header,params)
    end
    def delete(uri,header=nil,params={})
        self.request(:delete,uri,header,params)
    end
    def request(method,uri,header=nil,params=[])
        header = {"X-Auth-Token"=> self.auth_token } if header.nil?
        begin
            if method == :get then
                ua.get(uri, params,nil,header)  
            end

            if method == :post then
                header["Content-type"] = "application/json"
                ua.post(uri,params,header) 
            end
            if method == :delete then
                ua.delete(uri,params,header)
            end

        rescue =>e
            raise e
        end
        ua.page.body
    end
    def auth_token
        if @auth_token && @expires && @expires > Time.now then
            return @auth_token
        end

        uri = API_BASE_URI+"/authorize.json"
        self.get(uri ,{"X-Auth-User"=>@user,"X-Auth-Key"=>@auth_key})

        @auth_token = JSON.parse(ua.page.body)["auth_token"]
        @expires = Time.now+60*60*24
        @auth_token
    end

    def zone_delete(name_or_id)
        zone_id = ( name_or_id =~ /\d+/ ) ? name_or_id : self.find_zone_id(name_or_id)
        url = API_BASE_URI+"/zone/delete/#{zone_id}.json"
        self.delete(url)
    end
    def zone_create_new(name,email)
        params_str = {name:name, mailaddress:email, add_google_apps:false}.to_json
        url = API_BASE_URI+"/zone/create.json"
        self.post(url,nil,params_str)
    end

    def zone_list
         uri = API_BASE_URI+"/zone.json"
         ret = self.get(uri)
         @domains = JSON.parse(ret)["domain"]
    end
    def record_list(zone_name)
        uri = API_BASE_URI+"/record/#{zone_name}.json"
        ret = self.get(uri)
        @records = JSON.parse(ret)["record"]
    end
    def find_zone_id(name)
        zone = self.zone_list.find{|e| 
            name =~/#{e["name"]}/
        }
        return nil unless zone
        return zone["id"]
    end
    def zone_exists?(name)
        self.find_zone_id(name)!=nil
    end
    def record_name(id)
        ## TODO dns round robin
        zone = self.zone_list.each{|zone| 
          record = self.record_list(zone["name"]).each{|record|
            return record["name"] if record['id'] == id 
          }
        }
        return nil
    end

    def find_record_id(name)
        ## TODO dns round robin
        zone = self.zone_list.find{|e| 
            name =~/#{e["name"]}/
        }
        return nil unless zone
        record = self.record_list(zone["name"]).find{|e|
            name =~/#{e["name"]}/
        }
        return nil unless record
        record["id"]
    end
    def record_exists?(record_name)
        self.find_record_id(record_name)!=nil
    end
    def record_delete(name_or_id)
        record_id = ( name_or_id =~ /\d+/ ) ? name_or_id : self.find_record_id(name_or_id)
        url = API_BASE_URI+"/record/delete/#{record_id}.json"
        self.delete(url)
    end
    def record_create(name,zone,content=nil,type="A",prio=10,ttl=7200)
        if name =~/#{zone}/ then
            name = name.gsub(/\.#{zone}/,"" )
        end
        content ||= self.current_global_ip
        raise unless self.zone_exists? zone

        param = { 
            domain: zone,
            name: name,
            type: type,
            prio: prio,
            content: content,
            ttl: ttl,
        }.to_json

        url = API_BASE_URI+"/record/create.json"
        self.post(url,nil,param)
        

            
    end
    def record_update(record_id_or_name,prio=10,content=nil,ttl=7200,force=false)
        ## TODO dns round robin
        record_id = ( record_id_or_name =~ /\d+/ ) ? record_id_or_name : self.find_record_id(record_id_or_name)
        content = self.current_global_ip unless content 
        params = {"prio"=>prio,"content"=>content,"ttl"=>ttl}.to_json
        url = API_BASE_URI+"/record/update/#{record_id}.json"
        ret = self.post(url,nil,params)
        JSON.parse(ret)["record"]
    end
    def address_is_changed?(record_id_or_name,content=nil)
        ## TODO dns round robin
        record_name = ( record_id_or_name =~ /\d+/ ) ? self.record_name(record_id_or_name): record_id_or_name
        current_dns_result = Resolv.getaddresses(record_name)
        if current_dns_result 
          current_dns_result = current_dns_result.first
        end
        replace_content   = (content) ? content : self.current_global_ip
        return current_dns_result != replace_content
    end
    alias :address_is_changed :address_is_changed?
    def current_global_ip
        url = "http://myexternalip.com/json"
        ret = self.get(url,{},[])
        ret = JSON.parse(ret)["ip"]
    end

end
