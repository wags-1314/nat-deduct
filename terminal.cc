#include "terminal.hh"

std::ostream& fg::red(std::ostream& out) { return out << RED; }

std::ostream& fg::green(std::ostream& out) { return out << GREEN; }

std::ostream& fg::reset(std::ostream& out) { return out << RESET; }