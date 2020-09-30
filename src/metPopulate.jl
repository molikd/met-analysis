using ArgParse
using LibPQ

# to run: Julia met-populate.jl -n silva -l "https://ftp.arb-silva.de/release_100/ARB_files/SSUParc_100_SILVA_02_08_09_opt.arb"
# have to figure out how to add as bin script

function parse_commandline()
	s = ArgParseSettings()

	@add_arg_table s begin
		"--name", "-n"
			help = "name of database to be inserted"
			arg_type = String
			required = true
		"--link", "-l"
			help = "link to database"
			required = true
		"--overwrite", "-r"
            help = "option to overwrite existing table (true or false)"
            default = false
	end

	return parse_args(s)
end

# insertDB just connects to database currently, need to figure out postgresql command to insert from link
# check to see if table exists, if overwrite = true then overwrite, if false give error message
# if table doesnt exist insert as normal

function insertDB(name, link, overwrite)
	host="127.0.0.1"
	port="5432"
	db="met"
	user="cdevoto_nopass"

	conn = LibPQ.Connection("host=$host dbname=$db user=$user password=$pwd")

	result = LibPQ.execute(conn, "CREATE TABLE $name (test varchar(10) PRIMARY KEY);")


end

function main()
	parsed_args = parse_commandline()
	
	insertDB(parsed_args["name"], parsed_args["link"], parsed_args["overwrite"])
	println("Parsed args:")
	for (arg,val) in parsed_args
        println("  $arg  =>  $val")
	end
end

main()
