#ifndef TERMINAL_HH
#define TERMINAL_HH

#include <ostream>

#define RESET "\033[0m"
#define BLACK "\033[30m"
#define RED "\033[31m"

namespace fg {

std::ostream& red(std::ostream&);

}

std::ostream& reset(std::ostream&);

#endif