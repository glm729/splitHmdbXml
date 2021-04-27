#!/usr/bin/env julia

println("\e[34mInitialising\e[0m")


# Function definitions
# -----------------------------------------------------------------------------

# Initialise output store
function init_out()
  return Dict{String,Union{Nothing,String,Array{String,1}}}(
    "id" => nothing,
    "text" => Array{String,1}()
  )
end

# Prepare the text for the XML output
function xml_text(content::Array{String,1})::String
  local xml_start::Array{String,1} = [
    """<?xml version="1.0" encoding="UTF-8"?>""",
    """<hmdb xmlns="http://www.hmdb.ca">"""
  ]
  local xml_end::String = "</hmdb>"
  return "$(join(xml_start, "\n"))\n$(join(content, "\n"))\n$xml_end\n"
end

# Write the data out
function write_xml(
    out::Dict{String,Union{Nothing,String,Array{String,1}}},
    dir_out::String
  )::Bool
  local id::String
  id = isnothing(out["id"]) ? "IDNA_$(lpad(string(idna), 7, "0"))" : out["id"]
  open("$dir_out/$(out["id"]).xml", "w") do file
    write(file, xml_text(out["text"]))
  end
  return true
end


# Operations
# -----------------------------------------------------------------------------

cd("../hmdb_data/")
if !isdir("./all_split")
  mkdir("./all_split")
end

# Define paths to use
path = Dict{Symbol,String}(
  :xml => "./hmdb_metabolites.xml",
  :dir_out => "./all_split"
)

# DEBUG
# global stop = 0

println("\e[34mRunning operations\e[0m")

global idna = 0
global out = init_out()

for line in eachline(path[:xml])
  # Ignore matching
  if occursin(r"^\<(\/)?(hmdb|\?xml)", line)
    continue
  end
  push!(out["text"], line)
  # While no ID, check if current row is ID
  if isnothing(out["id"])
    m = match(r"\<accession\>(?<id>HMDB\d+)\<\/accession\>", line)
    if !isnothing(m)
      out["id"] = string(m[:id])
    end
  end
  # If end of metabolite data, write out and reset
  if occursin(r"^\<\/metabolite\>", line)
    write_xml(out, path[:dir_out])
    if isnothing(out["id"])
      global idna += 1
    end
    global out = init_out()
    # DEBUG
    # global stop += 1
    # if stop > 9
    #   break
    # end
  end
end

println("\e[32mOperations complete\e[0m")
