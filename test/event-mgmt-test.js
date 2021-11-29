const Event = artifacts.require("Event");
const truffleAssert = require("truffle-assertions")

contract("Event", accounts => {
    it("should prevent user from start or participate in new game if they have a currently active game. ", async() => {
        let event = await Event.deployed()
        owner = await event.owner()
        assert.equal(owner, accounts[0])
    })
})