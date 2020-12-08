module API_calls

using HTTP

export insert_API_taxa

########### TAXA ###########

function insert_API_taxa(order, family, genus, species)
	url = string("http://0.0.0.0:5000/met/taxa/add?ordo=", order, "&familia=", family, "&genus=", genus, "&species=", species)
	try
		response = HTTP.post(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end

function delete_API_taxa(taxon_id)
	url = string("http://0.0.0.0:5000/met/taxa/delete?taxon_id=", taxon_id)
	try
		response = HTTP.get(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end

function get_API_taxa(ordo, familia, genus, species)
    url = string("http://0.0.0.0:5000/met/taxa/id?ordo=", ordo, "&familia=", familia, "&genus=", genus, "&species=", species)
    try
        response = HTTP.get(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

########### TAXA_SEQ_ID ###########


function insert_API_seqID(taxon_id, sequence, source, external_identifier)
    url = string("http://0.0.0.0:5000/met/taxa/seq_assign?taxon_id=", taxon_id, "&sequence=", sequence, "&source=", source, "&external_identifier=", external_identifier)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

function delete_API_seqID(seq_id)
    url = string("http://0.0.0.0:5000/met/taxa/seq_delete?seq_id=", seq_id)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

########### DATASET ###########

function insert_API_dataset(external_identifier, external_name, external_url)
	url = string("http://0.0.0.0:5000/met/dataset/add?external_identifier=", external_identifier, "&external_name=", external_name, "&external_url=", external_url)
	try
		response = HTTP.post(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end

function get_API_dataset(external_identifier)
	url = string("http://0.0.0.0:5000/met/dataset/dataset_id?external_identifier=", external_identifier)
	try
        response = HTTP.get(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end


function insert_API_datasetmetadata(dataset_id, dataset_external_identifier, project_id, collection_identifier, experiment_identifier, sample_name, study_identifier, assay_type, AvgSpotLen, publisher, collection_date, sample_depth, sample_elev, sample_sal, env_biome, env_feature, env_material, geo_loc_name_country, geo_loc_name_country_continent, geo_loc_name, loc_type, sequencing_instrument, isolation_source, lat_lon, library_name, library_layout, library_selection, library_source, MBases, MBytes, sequencing_platform, release_date)
	
	url = string("http://0.0.0.0:5000/met/dataset/addmetadata?dataset_id=", dataset_id, "&dataset_external_identifier=", dataset_external_identifier, "&project_id=", project_id, "&collection_identifier=", collection_identifier, "&experiment_identifier=", experiment_identifier, "&sample_name=", sample_name, "&study_identifier=", study_identifier, "&assay_type=", assay_type, "&AvgSpotLen=", AvgSpotLen, "&publisher=", publisher, "&collection_date=", collection_date, "&sample_depth=", sample_depth, "&sample_elev=", sample_elev, "&sample_sal=", sample_sal, "&env_biome=", env_biome, "&env_feature=", env_feature, "&env_material=", env_material, "&geo_loc_name_country=", geo_loc_name_country, "&geo_loc_name_country_continent=", geo_loc_name_country_continent, "&geo_loc_name=", geo_loc_name, "&loc_type=", loc_type, "&sequencing_instrument=", sequencing_instrument, "&isolation_source=", isolation_source, "&lat_lon=", lat_lon, "&library_name=", library_name, "&library_layout=", library_layout, "&library_selection=", library_selection, "&library_source=", library_source, "&MBases=", MBases, "&MBytes=", MBytes, "&sequencing_platform=", sequencing_platform, "&release_date=", release_date)
	try
		response = HTTP.post(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end


function delete_API_dataset(dataset_id)
	url = string("http://0.0.0.0:5000/met/dataset/delete?dataset_id=", dataset_id)
	try
		response = HTTP.post(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end


########### DESCRIPTIONS ###########

# NOTE: description must be in json form, i.e. {}

function insert_API_descriptions(taxon_id, description, name)
    url = string("http://0.0.0.0:5000/met/description/add?taxon_id=", taxon_id, "&description=", description, "&name=", name)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

function delete_API_descriptions(description_id)
    url = string("http://0.0.0.0:5000/met/description/delete?description_id=", description_id)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

########### PROJECTS ###########

# NOTE: dataset_id must be entered as a int[], i.e. {1}


function insert_API_projects(project_name, external_identifier, external_name, dataset_ids)
    url = string("http://0.0.0.0:5000/met/projects/add?project_name=", project_name, "&external_identifier=", external_identifier, "&external_name=", external_name, "&dataset_ids=", dataset_ids)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

function delete_API_projects(association_id)
    url = string("http://0.0.0.0:5000/met/projects/delete?association_id=", association_id)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

function get_API_projects(external_identifier)
    url = string("http://0.0.0.0:5000/met/projects/project_id?external_identifier=", external_identifier)
    try
        response = HTTP.get(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end


########### ASV ###########

function insert_API_asv(sequence, quality_score, gene_region)
	url = string("http://0.0.0.0:5000/met/asv/add?sequence=", sequence, "&quality_score=", quality_score, "&gene_region=", gene_region)
	try
		response = HTTP.post(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end

function delete_API_asv(asv_id)
	url = string("http://0.0.0.0:5000/met/asv/delete?asv_id=", asv_id)
	try
		response = HTTP.post(url)
		return String(response.body)
	catch e
		return "Error occured: $e"
	end
end


########### ASV_ASSIGNMENT ###########


function insert_API_asvAssignment(asv_id, dataset_id, amount_found)
    url = string("http://0.0.0.0:5000/met/asv/assign_dataset?asv_id=", asv_id, "&dataset_id=", dataset_id, "&amount_found=", amount_found)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

function delete_API_asvAssignment(asv_assignment_id)
    url = string("http://0.0.0.0:5000/met/asv/delete_dataset?asv_assignment_id=", asv_assignment_id)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

########### TAXON_ASSIGNMENT ###########

function insert_API_taxonAssignment(asv_id, taxon_id, assignment_score, assignment_tool)
    url = string("http://0.0.0.0:5000/met/asv/assign_taxa?asv_id=", asv_id, "&taxon_id=", taxon_id, "&assignment_score=", assignment_score, "&assignment_tool=", assignment_tool)
    try
        response = HTTP.post(url)
        return String(response.body)
    catch e
        return "Error occured: $e"
    end
end

# Unsure about delete function bc there are two primary keys

end
