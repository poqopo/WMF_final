/** Contract created based on: https://docs.chain.link/docs/get-a-random-number
 *  Contract created only for educational purposes, by: github.com/dappuniversity
 *  You will need testnet ETH and LINK.
 *     - Rinkeby ETH faucet: https://faucet.rinkeby.io/
 *     - Rinkeby LINK faucet: https://rinkeby.chain.link/
 */

/** !UPDATE
 * min. bet >= $1 in Ethereum
 * 
 * ETH/USD price will be received from Chainlink Oracles prices feed aggregator.
 * more: https://docs.chain.link/docs/using-chainlink-reference-contracts.
 */
pragma solidity 0.6.6;

import "./Token/We_Made_Future.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract BettingGame is VRFConsumerBase {
    
  We_Made_Future public WMF; 

  uint256 internal fee;
  uint256 public randomResult;
  
  //Network: Rinkeby
  address constant VFRC_address = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B; // VRF Coordinator
  address constant LINK_address = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709; // LINK token
  
  //declaring 50% chance, (0.5*(uint256+1))
  uint256 constant half = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  
  //keyHash - one of the component from which will be generated final random value by Chainlink VFRC.
  bytes32 constant internal keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
  
  uint256 public gameId;
  uint256 public lastGameId;
  address public admin;
  mapping(uint256 => Game) public games;

  struct Game{
    uint256 id;
    uint256 bet;
    uint256 seed;
    uint256 amount;
    address player;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin, 'caller is not the admin');
    _;
  }

  modifier onlyVFRC() {
    require(msg.sender == VFRC_address, 'only VFRC can call this function');
    _;
  }
  
  event Withdraw(address admin, uint256 amount);
  event Received(address indexed sender, uint256 amount);
  event Result(uint256 id, uint256 bet, uint256 randomSeed, uint256 amount, address player, uint256 winAmount, uint256 randomResult, uint256 time);
  
  /**
   * Constructor inherits VRFConsumerBase.
   */
  constructor(We_Made_Future _WMF) VRFConsumerBase(VFRC_address, LINK_address) public {
    fee = 0.1 * 10 ** 18; // 0.1 LINK
    admin = msg.sender;
    WMF = _WMF;
  }
  
  /**
   * Taking bets function.
   * By winning, user 2x his betAmount.
   * Chances to win and lose are the same.
   */
  function game(uint256 amount, uint256 bet, uint256 seed) public returns (bool) {
    //bet=0 is low, refers to 1-3  dice values
    //bet=1 is high, refers to 4-6 dice values
    require(bet<=1, 'Error, accept only 0 and 1');

    //vault balance must be at least equal to msg.value
    require(WMF.balanceOf(address(this))>=amount, 'Error, insufficent vault balance');
    
    //each bet has unique id
    games[gameId] = Game(gameId, bet, seed, amount, msg.sender);

    WMF.transfer(address(this), amount);
    
    //increase gameId for the next bet
    gameId = gameId+1;

    //seed is auto-generated by DApp
    getRandomNumber(seed);
    
    return true;
  }
  
  /** 
   * Request for randomness.
   */
  function getRandomNumber(uint256 userProvidedSeed) internal returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) > fee, "Error, not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  /**
   * Callback function used by VRF Coordinator.
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    randomResult = randomness;

    //send final random value to the verdict();
    verdict(randomResult);
  }
  
  /**
   * Send rewards to the winners.
   */
  function verdict(uint256 random) public onlyVFRC {
    //check bets from latest betting round, one by one
    for(uint256 i=lastGameId; i<gameId; i++){
      //reset winAmount for current user
      uint256 winAmount = 0;
      
      //if user wins, then receives 2x of their betting amount
      if((random>=half && games[i].bet==1) || (random<half && games[i].bet==0)){
        winAmount = games[i].amount*2;
        address winner = games[i].player;
        WMF.transferFrom(address(this), winner, winAmount);
      }
      emit Result(games[i].id, games[i].bet, games[i].seed, games[i].amount, games[i].player, winAmount, random, block.timestamp);
    }
    //save current gameId to lastGameId for the next betting round
    lastGameId = gameId;
  }
  
  /**
   * Withdraw LINK from this contract (admin option).
   */
  function withdrawLink(uint256 amount) external onlyAdmin {
    require(LINK.transfer(msg.sender, amount), "Error, unable to transfer");
  }
  
  function withdrawWMF(uint256 amount) external  onlyAdmin {
  require(WMF.balanceOf(address(this))>=amount, 'Error, contract has insufficent balance');
  WMF.transfer(admin, amount);

  emit Withdraw(admin, amount);
}
}
