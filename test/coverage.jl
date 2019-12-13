using Pkg
Pkg.add("Coverage")

using Coverage
CodeCov.Codecov.submit_local(process_folder())
