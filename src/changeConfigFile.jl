# script for users to change information in config.yml to run metAPI
# uses argparse to get new values
# to run: Julia changeConfigFile.jl -d met -u cdevoto -w no_pass -t 127.0.0.1 -p 5432

using ConfParser
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
		"--database", "-d"
            help = "name of database"
            arg_type = String
            required = true
        "--username", "-u"
            help = "username of database"
            arg_type = String
            required = true
		"--password", "-w"
            help = "password of user"
            arg_type = String
		"--host", "-t"
            help = "host of database"
            arg_type = String
            required = true
        "--port", "-p"
            help = "port of database"
            required = true
    end

    return parse_args(s)
end


function changeConfigFile()
	parsed_args = parse_commandline()
	
	conf = ConfParse("config.yml")
	parse_conf!(conf)

	# added string() to enter it into yml with single quotes

	commit!(conf, "database", string("'", parsed_args["database"], "'"))	
	commit!(conf, "username", string("'", parsed_args["username"], "'"))
	commit!(conf, "password", string("'", parsed_args["password"], "'"))
	commit!(conf, "host", string("'", parsed_args["host"], "'"))
	commit!(conf, "port", string("'", parsed_args["port"], "'"))

	save!(conf)
		
end

changeConfigFile()

