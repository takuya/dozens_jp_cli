require "dozens_jp_cli/version"


class Dozens
    attr_accessor :ua

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
    def request(method,uri,header=nil,params=[])
        header = {"X-Auth-Token"=> @auth_token } unless header
        begin 
            ua.get(uri, params,nil,header)  if method == :get
            ua.post(uri,params,header) if method == :post
        rescue =>e
            raise e
        end
        ua.page.body
    end
    def auth_token
        if @auth_token && @expires && @expires > Time.now then
            return @auth_token
        end
        begin 
            self.get("http://dozens.jp/api/authorize.json",{"X-Auth-User"=>@user,"X-Auth-Key"=>@auth_key})
        rescue =>e
            raise e
        end
        @auth_token = JSON.parse(ua.page.body)["auth_token"]
        @expires = Time.now+60*60*24
        @auth_token
    end

    def zone_list
         uri = "http://dozens.jp/api/zone.json"
         ret = self.get(uri)
         @domains = JSON.parse(ret)["domain"]
    end
    def record_list(zone_name)
        uri = "http://dozens.jp/api/record/#{zone_name}.json"
        ret = self.get(uri)
        @records = JSON.parse(ret)["record"]
    end
    def find_record_id(name)
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
    def record_update(record_id,prio=10,content=nil,ttl=7200)
        content = self.current_global_ip unless content 
        params = {"prio"=>prio,"content"=>content,"ttl"=>ttl}.to_json
        url = "http://dozens.jp/api/record/update/#{record_id}.json"
        ret = self.post(url,nil,params)
        @records = JSON.parse(ret)["record"]
    end

    def current_global_ip
        url = "http://myexternalip.com/json"
        ret = self.get(url)
        ret = JSON.parse(ret)["ip"]
    end




end
