# Met-Analysis

Met Analysis is a Julia analysis package for Met (View API layer [here](https://github.com/molikd/met-api)).

## Usage

Use the sign in function found in [changeConfig.jl](https://github.com/molikd/met-analysis/blob/master/src/changeConf.jl) to first update the credentials and configuration files.

```bash
julia> using changeConfig
julia> changeConfig.signin(username, apiKey, Dict("met_domain"=>"your_met_domain"), Dict("met_api_domain"=>"your_met_api_domain"), Dict("toolkitpath"=>"your_toolkitpath"), Dict("storagepath"=>"your_storagepath"))
```

If you do not specify met_domain, met_api_domain, toolkitpath, or storagepath, it will be set to the default options.

You can view your configurations with the command

```bash
julia> changeConfig.get_config()
```

If you need to alter the config file, use the command

```bash
julia> changeConfig.set_config_file("value"=>"your_value")
```
The config file is stored at the users homedirectory.met.config

## API_calls

This module, found in [API.jl](https://github.com/molikd/met-analysis/blob/master/src/API.jl), is the Julia layer of interaction with the Perl API. All API calls are made through this module. 

## metPopulate

Users can use the metPopulate module to populate different tables of the met database.

###### To insert a fasta file into the taxa and taxa_seq_id tables, run:

```bash
julia> using metPopulate
julia> metPopulate.fasta_insert(source_of_fasta_file, path_to_fasta_file)
```

For example:

```bash
julia> metPopulate.fasta_insert("silva", "/Users/carolinedevoto/test_silva.fasta")
```

###### To insert SRA run table information into the projects, datasets, and datasets_metadata tables, run the following command. 

Note: if the project identifier already exists in the project table, it will not insert and instead update projects.dataset_ids.

```bash
julia> metPopulate.SraRunInfo_insert(local_path, download_path) 
```

For example:

```bash
julia> metPopulate.SraRunInfo_insert("/Users/carolinedevoto/Downloads/SraRunTable-3.txt", "https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos1/sra-pub-run-1/SRR4734654/SRR4734654.1")

```
###### To insert FASTQ information from a SRA number into the asv and asv_assignment tables (if not already present), run the following command. 

Note: This requires the user to have downloaded the [SRA toolkit](https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit) provided by the NCBI. Specify the path to the toolkit as shown previously using changeConfig. The storage path specified in the config file is where the generated .fastq files will be stored.   

```bash
julia> metPopulate.SraFASTQ_insert(sra_num, gene_region)
```

For example:

```bash
metPopulate.SraFASTQ_insert("SRR4734645", "18S")
```
