
#import <Foundation/Foundation.h>

#include <im_core/src/bridge.rs.h>

#include <iostream>
#include <vector>

int main(int argc, const char *argv[])
{

    std::cout << "main ..." << std::endl;
    auto logger = im::core::new_logger();
    logger->warning("Hello world");
    logger->info("Hello world");
    return 0;
}
