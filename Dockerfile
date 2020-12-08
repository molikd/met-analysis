FROM julia:alpine

RUN julia -e 'Pkg.add("https://github.com/molikd/met-analysis")'
