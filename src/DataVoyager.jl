module DataVoyager

using Electron, DataValues, FilePaths

import IteratorInterfaceExtensions, TableTraits, IterableTables, JSON, VegaLite

export Voyager

app = nothing

mutable struct Voyager
    w::Window

    function Voyager()
        main_html_uri = URI(joinpath(@__PATH__, "htmlui", "main.html"))

        global app

        if app === nothing
            app = Application()
        end

        w = Window(app, main_html_uri, options=Dict("title" => "Data Voyager"))

        new(w)
    end
end

function (v::Voyager)(source)
    TableTraits.isiterabletable(source) === false && error("'source' is not a table.")

    it = IteratorInterfaceExtensions.getiterator(source)

    data_dict = Dict{String,Any}()

    data_dict["values"] = [Dict{Symbol,Any}(c[1] => isa(c[2], DataValue) ? (isna(c[2]) ? nothing : get(c[2])) : c[2] for c in zip(keys(r), values(r))) for r in it]

    data = JSON.json(data_dict)

    code = "voyagerInstance.updateData($data)"

    run(v.w, code)

return v
end

function Base.getindex(v::Voyager)
    code = "voyagerInstance.getSpec(true)"

    content = run(v.w, code)

    return VegaLite.VLSpec(content)
end

# function Base.getindex(v::Voyager, index::Int)
#     code = "voyagerInstance.getBookmarkedSpecs()"

#     content = run(v.w, code)

#     info(content)

#     return VegaLite.VLSpec(JSON.parse(content[index]))
# end

function Voyager(source)
    v = Voyager()

    v(source)

return v
end

end # module
