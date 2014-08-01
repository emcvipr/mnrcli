#mnrcli
```mnrcli``` provides an interactive console to navigate into EMC SRM & EMC SAS data.

It relies on cool technologies like [savon](https://github.com/savonrb/savon), [pry](https://github.com/pry/pry) & [ViPR SRM](http://www.emc.com/data-center-management/vipr-srm.htm)

#Installation

```
bundle
```

#Usage
```ruby
f["parttype=='LUN'"].available_properties
```

Write your results to a file

```
write "myfile.txt",filter["!name"].get_all.to_csv
```


```
(Cli)> puts f["name=='Availability'"].get_distinct(:name,:source,:unit).table
-------------+---------------------------+------
name         | source                    | unit
-------------+---------------------------+------
Availability | Watch4NetSnmpCollector-1  | %
Availability | Oracle-Database-Collector | MB
Availability | HDS-Collector             | %
Availability | APG_HEALTH                | %
Availability | VNXBlock-Collector        | %
Availability | RSC-LunMappingDetection   | %
Availability | VMWareCollector           | %
-------------+---------------------------+------
7 metrics

```

Host to LUN

```ruby
f["(devtype='Host') & parttype='Disk'"].get_properties(:device,:partsn,:part).each do |disk|
  puts f["parttype='LUN' & partsn=='#{disk[2]}'"].get_properties(:device,:part,:poolname)
end
```

Show documentation and help
```ruby
show-doc f.get_all
h
```

#Configuration
You can configure web-service connectivity in ```config.yml```


#Contributing
fork it, use it, break it, fix it, upgrade it...

#License


```
    Licensed under the Apache License, Version 2.0 (the "License"); you may
    not use this file except in compliance with the License. You may obtain
    a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    License for the specific language governing permissions and limitations
    under the License.
```



``Copyright (c) 2013 EMC Corporation.``
