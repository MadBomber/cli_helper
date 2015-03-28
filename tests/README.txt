The minitest framework depends upon pry.

HOWEVER, pry currently requires an older version
of Slop.  CliHelper is based upon version 4+ of Slop;
When pry/minitest gets updated, I will un update the
test suite for full automation.

For now the test file is more manual.  Run tests like
the following from the command line:

```bash
./cli_helper_test.rb --config config/sample.ini,config/sample.ini.erb
./cli_helper_test.rb --config config/sample.rb,config/sample.rb.erb
./cli_helper_test.rb --config config/sample.txt,config/sample.txt.erb
./cli_helper_test.rb --config config/sample.yml,config/sample.yml.erb
```

The test with config/sample.rb.erb with raise a MakesNoSenseToMe exception.
