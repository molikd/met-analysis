module changeConf

using JSON

# adapted from plotly utils.jl

struct MetError
    msg::String
end

struct MetCredentials
    username::String
    api_key::String
end

mutable struct MetConfig
    met_domain::String
    met_api_domain::String
    met_streaming_domain::String
    met_proxy_authorization::Bool
    met_ssl_verification::Bool
    sharing::String
    world_readable::Bool
    auto_open::Bool
    fileopt::Symbol
	toolkitpath::String
end

const DEFAULT_CONFIG = MetConfig(
    "https://127.0.0.1:5000",
    "https://127.0.0.1:5000",
    "127.0.0.1:5000",
    false,
    true,
    "public",
    true,
    true,
    :create,
	""
)

function Base.merge(config::MetConfig, other::AbstractDict)
    MetConfig(
        [
            get(other, string(name), getfield(config, name))
            for name in fieldnames(MetConfig)
        ]...
    )
end

Base.show(io::IO, config::MetConfig) = dump(IOContext(io, :limit=>true), config)

function Base.Dict(config::MetConfig)
    Dict(k => getfield(config, k) for k in fieldnames(MetConfig))
end

"""
    signin(username::String, api_key::String, endpoints=nothing)
Define session credentials/endpoint configuration, where endpoint is a Dict
"""
function signin(
        username::String, api_key::String,
        endpoints::Union{Nothing,AbstractDict}=nothing,
		toolkitpath::Union{Nothing, AbstractDict}=nothing
	)
    global metcredentials = MetCredentials(username, api_key)



    # if endpoints are specified both the base and api domains must be
    # specified
    if endpoints != nothing
        if !haskey(endpoints, "met_domain") || !haskey(endpoints, "met_api_domain")
            error("You must specify both the `met_domain` and `met_api_domain`")
        end
        global metconfig = merge(DEFAULT_CONFIG, endpoints)
    end
	if toolkitpath != nothing
		global metconfig = merge(DEFAULT_CONFIG, toolkitpath)
	end
end

"""
    get_credentials()
Return the session credentials if defined --> otherwise use .credentials specs
"""
function get_credentials()
	try
		return metcredentials
	catch
		creds = merge(get_credentials_file(), get_credentials_env())
		try
			username = creds["username"]
			api_key = creds["api_key"]
			
			global metcredentials = MetCredentials(username, api_key)
			return metcredentials
		catch
			error("Please 'signin(username, api_key)' before proceeding")
		end
	end
end

"""
    get_config()
Return the session configuration if defined --> otherwise use .config specs
"""
function get_config()
	try
		return metconfig
	catch
		config = get_config_file()
		global metconfig = merge(DEFAULT_CONFIG, config)
		return metconfig
	end
end

"""
    set_credentials_file(input_creds::AbstractDict)
Save Plotly endpoint configuration as JSON key-value pairs in
userhome/.plotly/.credentials. This includes username and api_key.
"""
function set_credentials_file(input_creds::AbstractDict)
    credentials_folder = joinpath(homedir(), ".met")
    credentials_file = joinpath(credentials_folder, ".credentials")

    # check to see if dir/file exists --> if not, create it
    !isdir(credentials_folder) && mkdir(credentials_folder)

    prev_creds = get_credentials_file()
    creds = merge(prev_creds, input_creds)

    # write the json strings to the cred file
    open(credentials_file, "w") do creds_file
        write(creds_file, JSON.json(creds))
    end
end

"""
    set_config_file(input_config::AbstractDict)
Save Met endpoint configuration as JSON key-value pairs in
userhome/.met/.config. This includes the met_domain, and
met_api_domain.
"""
function set_config_file(input_config::AbstractDict)
    config_folder = joinpath(homedir(), ".met")
    config_file = joinpath(config_folder, ".config")

    # check to see if dir/file exists --> if not create it
    !isdir(config_folder) && mkdir(config_folder)

    prev_config = get_config_file()
    config = merge(prev_config, input_config)

    # write the json strings to the config file
    open(config_file, "w") do config_file
        write(config_file, JSON.json(config))
    end
end

"""
    set_config_file(config::PlotlyConfig)
Set the values in the configuration file to match the values in config
"""
set_config_file(config::MetConfig) = set_config_file(Dict(config))

"""
    get_credentials_file()
Load user credentials informaiton as a dict
"""
function get_credentials_file()
    cred_file = joinpath(homedir(), ".met", ".credentials")
    filesize(cred_file) != 0 ? JSON.parsefile(cred_file) : Dict()
	#isfile(cred_file) ? JSON.parsefile(cred_file) : Dict()
end

function get_credentials_env()
    out = Dict()
    keymap = Dict(
        "MET_USERNAME" => "username",
        "MET_APIKEY" => "api_key",
    )
    for k in ["MET_USERNAME", "MET_APIKEY"]
        if haskey(ENV, k)
            out[keymap[k]] = ENV[k]
        end
    end
    out
end

"""
    get_config_file()
Load endpoint configuration as a Dict
"""
function get_config_file()
    config_file = joinpath(homedir(), ".met", ".config")
    #isfile(config_file) ? JSON.parsefile(config_file) : Dict()
	filesize(config_file) != 0 ? JSON.parsefile(config_file) : Dict()
end

end
