#include "../../src/Example.h" // FIXME

#include <gtest/gtest.h>

struct ExampleTest : public testing::Test {
	Example example;
};

TEST_F(ExampleTest, IsGood) {
	/*  */
}
