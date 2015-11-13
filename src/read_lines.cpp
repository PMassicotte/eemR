#include <fstream>
#include <sstream>
#include <string>
#include <Rcpp.h>
using namespace Rcpp;

//' Faster read lines
//'
//' @param path File name or folder containing fluorescence file(s).
// [[Rcpp::export]]
std::vector<Rcpp::CharacterVector> read_lines(std::string path) {

  std::vector<Rcpp::CharacterVector> res;

  std::ifstream input(path.c_str());

  int pos = 0;

  for( std::string line; getline(input, line); )
  {
    res.push_back(line);
  }

  return(res);
}
