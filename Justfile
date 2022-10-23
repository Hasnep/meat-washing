default: build

install_dependencies:
	julia --project=. -e 'import Pkg; Pkg.instantiate()'

build:
	julia --project=. build.jl

dev:
	julia --project=. dev.jl

tag:
	git tag $(date --utc -u +%Y-%m-%dT%H:%M:%S)
	git push origin --tags
