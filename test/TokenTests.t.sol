// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Digiverse.sol";

contract TokenTest is Test {
    SAS token;
    IUniswapV2Router02 router;
    IUniswapV2Pair pair;

    address owner = makeAddr("owner");
    address buyer = makeAddr("buyer");

    function setUp() public {
        token = new SAS();
        router = token.uniswapV2Router();
        pair = IUniswapV2Pair(token.uniswapV2Pair());

        vm.deal(owner, 100 ether);
        vm.deal(buyer, 100 ether);
    }

    function test_addLiquidity() public {
        token.approve(address(router), 50_000_000 ether);
        router.addLiquidityETH{value: 1 ether}(
            address(token),
            50_000_000 ether,
            50_000_000 ether,
            1 ether,
            owner,
            block.timestamp
        );

        assertGt(pair.balanceOf(owner), 0);
    }

    modifier addLiquidity() {
        token.approve(address(router), 50_000_000 ether);
        router.addLiquidityETH{value: 10 ether}(
            address(token),
            50_000_000 ether,
            50_000_000 ether,
            10 ether,
            owner,
            block.timestamp
        );
        // token.enableTrading();
        _;
    }

    function test_swap_buy() public addLiquidity {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(token);

        vm.startPrank(buyer);
        router.swapExactETHForTokens{value: 1 ether}(
            0,
            path,
            buyer,
            block.timestamp
        );
        vm.stopPrank();

        uint currentBalance = token.balanceOf(buyer);
        assertGt(currentBalance, 0);

        token.swapAndLiquifyEnabled();
        vm.startPrank(buyer);
        router.swapExactETHForTokens{value: 0.1 ether}(
            0,
            path,
            buyer,
            block.timestamp
        );
        vm.stopPrank();

        assertGt(token.balanceOf(buyer), currentBalance);
    }

    function test_swap_sell() public addLiquidity {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(token);

        vm.startPrank(buyer);
        router.swapExactETHForTokens{value: 1 ether}(
            0,
            path,
            buyer,
            block.timestamp
        );
        vm.stopPrank();

        uint currentBalance = token.balanceOf(buyer);
        uint currentETH = address(buyer).balance;
        assertGt(currentBalance, 0);
        console.log("tokenBalance: %s", token.balanceOf(address(token)));

        token.swapAndLiquifyEnabled();
        path[0] = address(token);
        path[1] = router.WETH();
        vm.startPrank(buyer);
        token.approve(address(router), currentBalance);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            currentBalance,
            0,
            path,
            buyer,
            block.timestamp
        );
        vm.stopPrank();

        assertEq(token.balanceOf(buyer), 0);
        assertGt(address(buyer).balance, currentETH);
    }
}
