#ifndef GENCPP_PAGERANKDSL_H
#define GENCPP_PAGERANKDSL_H
#include <iostream>
#include <cstdlib>
#include <climits>
#include <cstdbool>
#include <fstream>
#include <sys/time.h>
#include <boost/mpi.hpp>
#include <vector>
#include <map>
#include <bits/stdc++.h>
#include <boost/serialization/map.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/mpi/collectives.hpp>
#include "../graph.hpp"

using namespace std;
namespace mpi = boost::mpi;

void Compute_PR(graph g,float beta,float delta,int maxIter,
  float* pageRank);

#endif
