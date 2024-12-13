#include "password.hpp"
#include "user.hpp"
#include <cassert>
#include <iostream>

int main() {
    Password password("toto", false);
    User user(1, password);

    std::cout << "Encrypted password: " << password.str() << std::endl;

    user.save();

    User &retrieved_user = user.get(1);
    assert(retrieved_user.id == 1);

    int login_status = retrieved_user.login("toto");
    assert(login_status == 0);

    std::cout << "All tests passed!" << std::endl;
    return 0;
}
