#include <__PROJECT__/Example.h>

#include <gtest/gtest.h>

struct ExampleTest : public testing::Test {
	Example example;
};

TEST_F(ExampleTest, IsGood) {
	/*  */
}
