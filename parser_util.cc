#include "parser_util.hh"

#include <iostream>
#include <set>
#include <string>

Ast::Ast(const std::string str)
    : tag(Ast::TERM), term_val(str), left(nullptr), right(nullptr){};

Ast::Ast(Ast::Type tag, Ast *left, Ast *right)
    : tag(tag), left(left), right(right){};

std::set<std::string> Ast::collect_terms() {
    if (tag == Ast::TERM) {
        return std::set<std::string>({term_val});
    } else if (tag == Ast::NOT) {
        return left->collect_terms();
    } else {
        std::set<std::string> terms;
        terms.merge(left->collect_terms());
        terms.merge(right->collect_terms());
        return terms;
    }
}

bool Ast::is_and() { return tag == Ast::AND; }
bool Ast::is_or() { return tag == Ast::OR; }
bool Ast::is_not() { return tag == Ast::NOT; }
bool Ast::is_if() { return tag == Ast::IF; }
bool Ast::is_iff() { return tag == Ast::IFF; }
bool Ast::is_term() { return tag == Ast::TERM; }

void Ast::print_terms() {
    for (auto term : collect_terms()) {
        std::cout << term << ' ';
    }

    std::cout << '\n';
}

std::ostream &operator<<(std::ostream &out, const Ast &node) {
    switch (node.tag) {
        case Ast::NOT:
            out << "(not " << *node.left << ')';
            break;
        case Ast::AND:
            out << "(and " << *node.left << ' ' << *node.right << ')';
            break;
        case Ast::OR:
            out << "(or " << *node.left << ' ' << *node.right << ')';
            break;
        case Ast::IF:
            out << "(if " << *node.left << ' ' << *node.right << ')';
            break;
        case Ast::IFF:
            out << "(iff " << *node.left << ' ' << *node.right << ')';
            break;
        case Ast::TERM:
            out << node.term_val;
            break;
    }

    return out;
}

bool ast_equals(const Ast &op1, const Ast &op2) {
    if (op1.tag == Ast::TERM && op2.tag == Ast::TERM) {
        return op1.term_val == op2.term_val;
    } else if (op1.tag == Ast::NOT && op2.tag == Ast::NOT) {
        return ast_equals(*op1.left, *op2.left);
    } else if (op1.tag == op2.tag) {
        return ast_equals(*op1.left, *op2.left) &&
               ast_equals(*op1.right, *op2.right);
    } else
        return false;
}

std::ostream &operator<<(std::ostream &out, const Reason &reason) {
    switch (reason.tag) {
        case Reason::HYPOTHESIS:
            out << "Hypothesis";
            break;
        case Reason::AND_INTRO:
            out << "AndIntro: " << reason.step1 << ", " << reason.step2;
            break;
        case Reason::AND_ELIM_L:
            out << "AndElimLeft: " << reason.step1;
            break;
        case Reason::AND_ELIM_R:
            out << "AndElimRight: " << reason.step1;
            break;
        case Reason::REPEAT:
            out << "Repeat: " << reason.step1;
            break;
        case Reason::ASSUMPTION:
            out << "Assumption";
            break;
        case Reason::IMPL_INTRO:
            out << "ImplIntro: " << reason.step1 << ", " << reason.step2;
            break;
        case Reason::IMPL_ELIM:
            out << "ImplElim: " << reason.step1 << ", " << reason.step2;
            break;
        case Reason::NOT_INTRO:
            out << "NotIntro: " << reason.step1 << ", " << reason.step2 << ", "
                << reason.step3;
            break;
        case Reason::NOT_ELIM:
            out << "NotElim: " << reason.step1;
            break;
        case Reason::OR_INTRO_L:
            out << "OrIntroLeft: " << reason.step1;
            break;
        case Reason::OR_INTRO_R:
            out << "OrIntroRight: " << reason.step1;
            break;
        case Reason::OR_ELIM:
            out << "OrElim: " << reason.step1 << ", " << reason.step2 << ", "
                << reason.step3;
            break;
        case Reason::IFF_INTRO:
            out << "IffIntro: " << reason.step1 << ", " << reason.step2;
            break;
        case Reason::IFF_ELIM_R:
            out << "IffElimR: " << reason.step1 << ", " << reason.step2;
            break;
        case Reason::IFF_ELIM_L:
            out << "IffElimL: " << reason.step1 << ", " << reason.step2;
            break;
    }

    return out;
}