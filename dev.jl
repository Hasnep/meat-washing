import HTTP

HTTP.listen("127.0.0.1", 8081) do stream::HTTP.Stream
    # file = joinpath(pwd(), "build", HTTP.unescapeuri(req.target[2:end]))
    # @info file
    # if isfile(file)
    #     return HTTP.Response(200, read(file))
    # else
    #     HTTP.Response(404)
    # end
    file = stream.message.target[2:end]
    @info file
    local_file_path = joinpath(pwd(), "build", file)
    @info local_file_path

    try
        data = read(local_file_path)
        write(stream, data)
    catch
        HTTP.setstatus(stream, 404)
        write(stream, "")
    end
end
