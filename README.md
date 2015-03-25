#mnrcli
```mnrcli``` provides an interactive console to navigate into EMC SRM & EMC SAS data.

It relies on cool technologies like [savon](https://github.com/savonrb/savon), [pry](https://github.com/pry/pry) & [ViPR SRM](http://www.emc.com/data-center-management/vipr-srm.htm)

#Installation

```
bundle
```

#Usage

Launch the console with  ```./mnrcli.rb -h <Web Server URL>```

Query the data
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

Get a list of Host Disks to LUNs

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

