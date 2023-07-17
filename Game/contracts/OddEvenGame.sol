// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OddEvenGame {
    enum Outcome {
        Even,
        Odd
    }

    struct Bet {
        address player;
        Outcome outcome;
        uint256 amount;
    }

    mapping(uint256 => Bet) public bets;
    mapping(address => uint256[]) public playerBets;

    uint256 public participationFee;
    uint256 public bettingLimit;
    uint256 public gameBalance;

    event BetPlaced(
        uint256 indexed betId,
        address indexed player,
        Outcome outcome,
        uint256 amount
    );
    event GameResult(
        uint256 indexed betId,
        Outcome outcome,
        uint256 winningAmount
    );
    event Withdraw(address indexed player, uint256 amount);

    constructor(uint256 _participationFee, uint256 _bettingLimit) {
        participationFee = _participationFee;
        bettingLimit = _bettingLimit;
    }

    modifier validOutcome(Outcome _outcome) {
        require(
            _outcome == Outcome.Even || _outcome == Outcome.Odd,
            "Invalid outcome"
        );
        _;
    }

    modifier withinBettingLimit(uint256 _amount) {
        require(
            _amount >= participationFee && _amount <= bettingLimit,
            "Amount is outside the betting limits"
        );
        _;
    }

    function placeBet(
        Outcome _outcome
    ) external payable validOutcome(_outcome) withinBettingLimit(msg.value) {
        uint256 betId = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );
        bets[betId] = Bet(msg.sender, _outcome, msg.value);
        playerBets[msg.sender].push(betId);
        gameBalance += msg.value;

        emit BetPlaced(betId, msg.sender, _outcome, msg.value);
    }

    function generateRandomNumber() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        blockhash(block.number - 1)
                    )
                )
            );
    }

    function distributeWinnings(uint256 _betId) public {
        Bet storage bet = bets[_betId];

        Outcome gameOutcome = Outcome(generateRandomNumber() % 2);
        uint256 winningAmount = 0;

        if (bet.outcome == gameOutcome) {
            winningAmount = bet.amount * 2;
            payable(bet.player).transfer(winningAmount);
        }

        emit GameResult(_betId, gameOutcome, winningAmount);
    }

    function withdraw(uint256 _betId) external {
        distributeWinnings(_betId);
        require(
            bets[_betId].player == msg.sender,
            "Only the player can withdraw"
        );
        require(bets[_betId].amount > 0, "No winning amount to withdraw");

        uint256 amount = bets[_betId].amount;
        bets[_betId].amount = 0;
        gameBalance -= amount;

        emit Withdraw(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}
