#ifndef THEOREM_HH
#define THEOREM_HH

#include <vector>

#include "parser_util.hh"

struct Theorem {
    Ast *hypothesis;
    Ast *goal;

    // std::vector<Step> proof;
};

#endif