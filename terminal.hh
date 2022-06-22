#ifndef TERMINAL_HH
#define TERMINAL_HH

#include <ostream>

#define RESET "\033[0m"
#define GREEN "\033[32m"
#define RED "\033[31m"

namespace fg {

/**
 * @brief      ostream manipulator, changes foreground to red
 *
 * @param      out   output stream
 *
 * @return     modified ostream
 */
std::ostream& red(std::ostream& out);

/**
 * @brief      ostream manipulator, changes foreground to green
 *
 * @param      out   output stream
 *
 * @return     modified ostream
 */
std::ostream& green(std::ostream& out);

/**
 * @brief      ostream manipulator, resets foreground
 *
 * @param      out   output stream
 *
 * @return     modified ostream
 */
std::ostream& reset(std::ostream& out);

}  // namespace fg

#endif