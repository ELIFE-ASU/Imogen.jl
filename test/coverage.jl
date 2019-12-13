using Pkg
Pkg.add("Coverage")

using Coverage
Codecov.submit_local(process_folder())
