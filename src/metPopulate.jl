module metPopulate

using ArgParse
using LibPQ
using FASTX

include("API.jl")
using .API_calls

# to run: Julia pop.jl -s silva -p "/Users/carolinedevoto/Downloads/SILVA_138.1_SSU_tax_silva_trunc.fasta"
# to run: Julia pop.jl -s silva -p "/Users/carolinedevoto/test_silva.fasta"
# have to figure out how to add as bin script

function parse_commandline()
	settings = ArgParseSettings()

	@add_arg_table settings begin
		"--source", "-s"
			help = "name of source to be inserted, ex. SILVA"
			arg_type = String
			required = true
		"--path", "-p"
			help = "path to fasta file"
			required = true
	end

	return parse_args(settings)
end

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

function main()
	parsed_args = parse_commandline()	
	fasta_insert(parsed_args["source"], parsed_args["path"])
end

main()

end
