class logstash-server{
#
# RabbitMQ
#
   package{"erlang": ensure=>present}
   package{"rabbitmq-server":
       ensure=>present,
       require=>Package["erlang"],
       provider=>dpkg,
       source=>"/vagrant/rabbitmq-server_2.3.1-1_all.deb"
   }
#
# Elastic Search
#
   package{["openjdk-6-jdk","git-core"]: ensure=>present}
   package{"elasticsearch":
     provider=>dpkg,
     source=>"/vagrant/elasticsearch-0.13.1_all.deb",
     ensure=>present,
     require=>Package["openjdk-6-jdk"]
   }

 
  
#
# Grok
#
   package{["libevent-1.4-2","libpcre3","libtokyocabinet8"]: ensure=>present}
   package{"grok":
     provider=>dpkg,
     source=>"/vagrant/grok-1.1_all.deb",
     ensure=>present,
     require=>Package["libevent-1.4-2","libpcre3","libtokyocabinet8"]
   }
   package{["ruby","ruby-dev","rubygems"]:ensure=>present}
   package{"jls-grok":
      ensure=>present,
      provider=>gem,
      require=>Package["grok","rubygems"]
   }

#
# Logstash itself
#
   package{"logstash": 
     provider=>gem,
     ensure=>present
   }

}
exec{"/usr/bin/aptitude update && touch /var/run/aptitude-updated":
        creates=>"/var/run/aptitude-updated",
            alias=>"apt-update"
}
file{"/etc/apt/apt.conf.d/01proxy":
      content=>"Acquire::http { Proxy \"http://liathach:3142\"; };"
}
Package{
       require=>[File["/etc/apt/apt.conf.d/01proxy"],Exec["apt-update"]]
}
include logstash-server
