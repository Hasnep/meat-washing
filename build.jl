import Literate
import Tar

function build(; run_pandoc = false, create_tarball = false)
    # Setup
    build_folder = joinpath(pwd(), "build")
    rm(build_folder, force = true, recursive = true)
    mkpath(build_folder)

    # Read frontmatter
    frontmatter = open(joinpath(pwd(), "frontmatter.yml")) do f
        read(f, String)
    end

    # Build markdown document
    Literate.markdown(
        joinpath(pwd(), "src", "meat-washing.jl"),
        build_folder;
        documenter = false,
        execute = true,
        # Fix auto-formatted hide comments
        preprocess = s -> replace(s, "# hide\n" => "#hide\n"),
        # Insert frontmatter
        postprocess = s -> "---\n$frontmatter\n---\n\n$s"
    )

    # Build to html using pandoc
    if run_pandoc
        @info "Building markdown to HTML."
        run(
            Cmd([
                "pandoc",
                joinpath(build_folder, "meat-washing.md"),
                "--from=markdown",
                "--to=html",
                "--standalone",
                "--output=" * joinpath(build_folder, "meat-washing.html"),
            ]),
        )
    end

    if create_tarball
        @info "Creating tarball file."
        Tar.create(build_folder, joinpath(pwd(), "meat-washing.tar"))
    end
end

if !isinteractive()
    build(run_pandoc = false, create_tarball = true)
end
