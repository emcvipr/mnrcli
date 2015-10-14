#mnrcli
```mnrcli``` provides an interactive console to navigate into EMC SRM & EMC SAS data.

It relies on cool technologies like [savon](https://github.com/savonrb/savon), [pry](https://github.com/pry/pry) & [ViPR SRM](http://www.emc.com/data-center-management/vipr-srm.htm)

#Installation

```
bundle
```

#Usage

Launch the console with  ```./mnrcli.rb -h <Web Server URL>```

Play with properties
```ruby
"parttype=='LUN'".available_properties
```


```
(Cli)> puts "name=='Availability'".get_distinct(:name,:source,:unit).table
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

Get a list of Host Disks to LUNs

```ruby
f["(devtype='Host') & parttype='Disk'"].get_properties(:device,:partsn,:part).each do |disk|
  puts f["parttype='LUN' & partsn=='#{disk[2]}'"].get_properties(:device,:part,:poolname)
end
```

Play with timeseries values
```
(Cli)> puts "parttype='LUN' & name='ResponseTime'&partsn='60060160000000000000000000000000'".get(:device,:part,:partsn,:value).table
---------------------------------+-----------------------+---------+-------
partsn                           | part                  | device  | value
---------------------------------+-----------------------+---------+-------
60060160000000000000000000000000 | LOGICAL UNIT NUMBER 0 | VNX0000 | 0.0
---------------------------------+-----------------------+---------+------
```

```
puts "parttype='LUN' & name='ResponseTime'&partsn='60060160000000000000000000000000'".get(:device,:part,:partsn,:value,:timestamp,:human_timestamp,all_values:true, offset:8640000).first(5).table
---------------------------------+-----------------------+---------+-------+------------+---------------------------------
partsn                           | part                  | device  | value | timestamp  | human_timestamp
---------------------------------+-----------------------+---------+-------+------------+---------------------------------
60060160000000000000000000000000 | LOGICAL UNIT NUMBER 8 | VNX1582 | 0.0   | 1420200033 | Fri, Jan  2 2015 07:00:33 -0500
60060160000000000000000000000000 | LOGICAL UNIT NUMBER 8 | VNX1582 | 0.0   | 1420200331 | Fri, Jan  2 2015 07:05:31 -0500
60060160000000000000000000000000 | LOGICAL UNIT NUMBER 8 | VNX1582 | 0.0   | 1420200635 | Fri, Jan  2 2015 07:10:35 -0500
60060160000000000000000000000000 | LOGICAL UNIT NUMBER 8 | VNX1582 | 0.0   | 1420200934 | Fri, Jan  2 2015 07:15:34 -0500
60060160000000000000000000000000 | LOGICAL UNIT NUMBER 8 | VNX1582 | 0.0   | 1420201231 | Fri, Jan  2 2015 07:20:31 -0500
---------------------------------+-----------------------+---------+-------+------------+---------------------------------
5 metrics
```

```
(Cli)> puts "myfilter".get(:human_timestamp, all_values:true, from:Date.today).table
--------------------------------
human_timestamp
--------------------------------
Fri, Apr 17 2015 00:13:04 -0400
Fri, Apr 17 2015 00:28:11 -0400
Fri, Apr 17 2015 00:43:17 -0400
Fri, Apr 17 2015 00:58:06 -0400
Fri, Apr 17 2015 01:28:16 -0400
Fri, Apr 17 2015 01:43:04 -0400
Fri, Apr 17 2015 01:58:09 -0400
Fri, Apr 17 2015 02:13:23 -0400
Fri, Apr 17 2015 02:28:05 -0400
Fri, Apr 17 2015 02:58:20 -0400
[...]
```

Show documentation and help
```ruby
show-doc f.get
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
