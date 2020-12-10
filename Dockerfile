FROM julia:alpine

RUN julia -e 'using Pkg; Pkg.add(url="https://github.com/molikd/met-analysis")'
