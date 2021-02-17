module metPopulate

using LibPQ
using FASTX
using CSV
using DataFrames
using Dates

include("metAPIcalls.jl")
include("changeConf.jl")
using .metAPIcalls
using .changeConf

### INSERT FASTA FILE INTO TAXA AND TAXA_SEQ_ID
### to run:
### metPopulate.fasta_insert(silva, "/Users/carolinedevoto/test_silva.fasta")

function fasta_insert(source, path)
 reader = open(FASTA.Reader, path)
    for record in reader
        # split description based on delimiter (domain-kingdom-phylum-class-order-family-genus-species)
        lst = rsplit(FASTA.description(record), ";")
        inserted = false
        try
            # indexing represents order, family, genus, species
            API_calls.insert_API_taxa(lst[4], lst[5], lst[6], lst[7])
            inserted = true
        catch e
            println("order, family, genus, species not all defined")
        end

        # only insert into taxa_seq_id if insertion into taxa was successful

        if inserted == true
            # API call to get taxon_id from taxa table, need it to insert into taxa_seq_id
            resp = API_calls.get_API_taxa(lst[4], lst[5], lst[6], lst[7])
            id = replace(resp, "[" => "")
            id = replace(id, "]" => "")

            API_calls.insert_API_seqID(parse(Int64, id), FASTA.sequence(record), source, FASTA.identifier(record))
        else
            println("error inserting in taxa, unable to insert in taxa_seq_id")
        end

    end
    close(reader)

end


### INSERT SRA RUN INFORMATION TO PROJECTS (IF NOT THERE), DATASETS, AND DATASET_METADATA
### to run: 
### metPopulate.SraRunInfo_insert("/Users/carolinedevoto/Downloads/SraRunTable-3.txt", "https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos1/sra-pub-run-1/SRR4734654/SRR4734654.1")

function SraRunInfo_insert(local_path, download_path)

	data = CSV.File(local_path, missingstring = "", delim = ',', limit = 1)
	data_df = DataFrame(data)

	# See if project identifier exists already in table, otherwise insert 
	
	project_id = API_calls.get_API_projects(data_df.Experiment[1])
	
	if project_id == "null"
		println("inserting experiment into table projects ... ")
		API_calls.insert_API_projects(data_df.Experiment[1], data_df.Experiment[1], data_df.BioProject[1])
	end

	# Insert run into dataset table

	try
		API_calls.insert_API_dataset(data_df.Run[1], data_df.Run[1], download_path)
	catch e
		println("error inserting into dataset table. Does run $data_df.Run[1] already exist in table?")
	end

	# Edit data_df to include only characters acceptable in URL

	unsafe_chars = [" ", "\\"]

	for col in eachcol(data_df, false)
		for c in unsafe_chars
			try
				col[1] = replace(col[1], c => "_")
			catch e	
				col[1] = col[1]
			end
		end
	end

	# Put collection_date in correct date format

	months = Dict("Jan" => 1, "Feb" => 2, "Mar" => 3, "Apr" => 4, "May" => 5, "June" => 6, "July" => 7, "Aug" => 8, "Sept" => 9, "Oct" => 10, "Nov" => 11, "Dec" => 12)
	date = split(data_df.Collection_Date[1], "-")
	month = date[1]
	year = date[2]
	month_num = months[month]
	date_new = Date(parse(Int64, year), month_num)

	# Retrieve dataset_id from dataset table
	
	id = API_calls.get_API_dataset(data_df.Run[1])
	dataset_id = replace(id, "[" => "")
    dataset_id = replace(dataset_id, "]" => "")

	# Add dataset_id to project_id table

	API_calls.update_API_projects(parse(Int64, dataset_id), data_df.Experiment[1])	

	# Retrieve project_id from project table	

	project_id = API_calls.get_API_projects(data_df.Experiment[1])
	project_id = replace(project_id, "[" => "")
    project_id = replace(project_id, "]" => "")

	# assign vars for dataset_metadata
	# think about what to do with variables that dont exist
    
	dataset_id = parse(Int64, dataset_id)
    dataset_external_identifier = data_df.Run[1]
    project_id = parse(Int64, project_id)
    collection_identifier = "unknown"
    experiment_identifier = "unknown"
    sample_name = data_df."Sample Name"[1]
    study_identifier = "unknown"
    assay_type = data_df."Assay Type"[1]
    AvgSpotLen = data_df.AvgSpotLen[1]
    publisher = data_df."Center Name"[1]
    collection_date = date_new
    sample_depth = data_df.Depth[1]
    sample_elev = "unknown"
    sample_sal = string(data_df.Salinity[1])
    env_biome = data_df.env_biome[1]
    env_feature = data_df.env_feature[1]
    env_material = data_df.env_material[1]
    geo_loc_name_country = data_df.geo_loc_name_country[1]
    geo_loc_name_country_continent = data_df.geo_loc_name_country_continent[1]
    geo_loc_name = data_df.geo_loc_name[1]
    loc_type = "unknown"
    sequencing_instrument = data_df.Instrument[1]
    isolation_source = "unknown"
    lat_lon = data_df.lat_lon[1]
    library_name = data_df."Library Name"[1]
    library_layout = data_df.LibraryLayout[1]
    library_selection = data_df.LibrarySelection[1]
    library_source = data_df.LibrarySource[1]
    MBases = ceil(Int64, data_df.Bases[1]/1000000)
    MBytes = ceil(Int64, data_df.Bytes[1]/1000000)
	sequencing_platform = data_df.Platform[1]
    release_date = data_df.ReleaseDate[1]

	API_calls.insert_API_datasetmetadata(dataset_id, dataset_external_identifier, project_id, collection_identifier, experiment_identifier, sample_name, study_identifier, assay_type, AvgSpotLen, publisher, collection_date, sample_depth, sample_elev, sample_sal, env_biome, env_feature, env_material, geo_loc_name_country, geo_loc_name_country_continent, geo_loc_name, loc_type, sequencing_instrument, isolation_source, lat_lon, library_name, library_layout, library_selection, library_source[1], MBases, MBytes, sequencing_platform, release_date)

end

### INSERT FASTQ INFORMATION FROM SRA NUM TO ASV AND ASV_ASSIGNMENT (IF NOT THERE)
### to run:
### metPopulate.SraFASTQ_insert("SRR4734645", "18S")

function SraFASTQ_insert(sra_num, gene_region)

    ## retrieve sra toolkit location and desired storage path for .fastq files from config file
    config = changeConf.get_config()
	toolkitpath = config.toolkitpath
    storagepath = config.storagepath


	## see if user specified where to store fastq files
    if storagepath == ""
        fastq_folder = joinpath(homedir(), ".fastq")
    else
        fastq_folder = joinpath(storagepath, ".fastq")
    end

    command = joinpath(toolkitpath, "bin/fasterq-dump")

    run(`$command $sra_num -O $fastq_folder`)
    fastq_filepath = joinpath(fastq_folder, string(sra_num, ".fastq"))

    ## dataset id will be the same for all (same sra number)
    dataset_id = API_calls.get_API_dataset(sra_num)
    dataset_id = replace(dataset_id, "[" => "")
    dataset_id = replace(dataset_id, "]" => "")

    ## create dictionary so we can access quality score and amount found for each sequence
    ## key == sequence, key[1] = quality score, key[2] = amount found
    seq_dict = Dict()

	reader = open(FASTQ.Reader, fastq_filepath)
        for record in reader
            ## extract information from each record
            sequence = string(FASTQ.sequence(record))
            quality = FASTQ.quality(record)

            ## calculate average quality score (FASTQ.quality gives hex vals)
            quality_sum = 0
            total = 0
            for num in quality
                val = convert(Int64, num)
                quality_sum = quality_sum + val
                total = total + 1
            end

            avg_quality = quality_sum / total

            ## look for sequence in dict
            ## if it is there, compare the quality scores and let highest remain, then incrememnt amount found
            ## if it is not there, insert into dictionary with quality score and amount found = 1

            try
                curr_quality = seq_dict[sequence][1]
                if avg_quality > curr_quality
                    seq_dict[sequence][1] = avg_quality
                end
                seq_dict[sequence][2] = seq_dict[sequence][2] + 1
            catch
                seq_dict[sequence] = [avg_quality, 1]
            end
        end
    close(reader)


	inserted = 0
    for seq in keys(seq_dict)
        try
            ## currently quality_score is type text in asv table
            API_calls.insert_API_asv(seq, string(floor(seq_dict[seq][1])), gene_region)
        catch e
            println("error inserting into asv table. is the sequence unique to the table?")
            inserted = 1
        end

        if inserted == 0
            asv_id = API_calls.get_API_asv(seq)
            asv_id = replace(asv_id, "[" => "")
            asv_id = replace(asv_id, "]" => "")

            API_calls.insert_API_asvAssignment(parse(Int64, asv_id), parse(Int64, dataset_id), convert(Int64, seq_dict[seq][2]))
        end
    end

end

end
