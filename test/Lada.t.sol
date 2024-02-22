//SPDX-License-Identifier: MIT

import "forge-std/Test.sol";
import "../src/audits/LadaToken/Token.sol";

contract Lada is Test {
    Token token;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        token = new Token();

        token.transfer(user1, 200 ether);
    }

    function test_replay_transferFrom() public {
        vm.prank(user1);

        token.approve(user2, 100 ether);

        vm.startPrank(user2);

        token.transferFrom(user1, user2, 100 ether);
        vm.expectRevert();
        token.transferFrom(user1, user2, 100 ether);

        console.log("User1 end balance", token.balanceOf(user1));
    }
}
