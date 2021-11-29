const Event = artifacts.require("Event");
const truffleAssert = require("truffle-assertions")

contract.skip("Event", accounts => {
    it("should assert event admin role.", async() => {
        let event = await Event.deployed()
        let owner = await event.owner()
        assert.equal(owner, accounts[0])
        await truffleAssert.passes(event.isAdmin(accounts[0]))
        await truffleAssert.passes(event.isAdmin(accounts[1]))
        await truffleAssert.passes(event.isAdmin(accounts[2]))
        await truffleAssert.passes(event.isAdmin(accounts[3]))
        await truffleAssert.reverts(event.isAdmin(accounts[4]))
        let numOfAdmins = await event.numOfAdmins()
        assert.equal(numOfAdmins.toNumber(), 4)
        let list = [accounts[2], accounts[3]]
        await event.removeAdmins(list)
        await truffleAssert.reverts(event.isAdmin(accounts[2]))
        await truffleAssert.reverts(event.isAdmin(accounts[3]))
        list = [accounts[4]]
        await event.addAdmins(list)
        numOfAdmins = await event.numOfAdmins()
        assert.equal(numOfAdmins.toNumber(), 3)
    })
    it("should allow registration of participants if conditions are met.", async() => {
        let event = await Event.deployed()
        let eventContractBalance = await event.totalBalance()
        assert.equal(eventContractBalance, 0)
        let eventNameOld = await event.eventName()

        await event.changeName("New Event Name")
        let eventNameNew = await event.eventName()
        assert(eventNameNew != eventNameOld)
        assert.equal(eventNameNew, "New Event Name")
        await event.register("John Doe", { from: accounts[2], value: 1000 })

        await truffleAssert.reverts(event.changeName("Newest Event Name"))
        let eventNameNewest = await event.eventName()
        assert(eventNameNew == eventNameNewest) //Didn't change because there's an active member already
        await truffleAssert.passes(event.isRegistered(accounts[2]))
        await truffleAssert.reverts(event.register("Adam Doe", { from: accounts[3], value: 100 })) //reverts with as a result of insufficient funds

        await truffleAssert.reverts(event.register("John Doe", { from: accounts[2], value: 1000 })) //Already a participant
        event.register("Adam Doe", { from: accounts[3], value: 1000 })
        event.register("Adam Doe", { from: accounts[5], value: 1000 })
        event.register("Adam Doe", { from: accounts[6], value: 1000 })
        event.register("Adam Doe", { from: accounts[7], value: 1000 })
        await truffleAssert.reverts(event.register("Adam Doe", { from: accounts[8], value: 1000 })) //Event is full so it reverts
        await event.setMaxParticipants(6) //increase maximum participants by 1
        await truffleAssert.passes(event.register("Adam Doe", { from: accounts[8], value: 1000 })) //passes as the event has one lucky slot
        await truffleAssert.reverts(event.register("Adam Doe", { from: accounts[9], value: 1000 })) //Event is full so it reverts again
    })
    it("should allow attendees to receive payout after event.", async() => {
        let event = await Event.deployed()
        let list1 = [accounts[5], accounts[6], accounts[7], accounts[9]] // accounts[9] is not registered
        let list2 = [accounts[5], accounts[6], accounts[7]]
        await truffleAssert.reverts(event.attend(list1)) // reverts as accounts[9] is not registered
        await truffleAssert.passes(event.attend(list2))
        await truffleAssert.reverts(event.endEvent({ from: accounts[3] })) // reverts as accounts[3] is not owner of event
        await truffleAssert.passes(event.endEvent()) // passes as accounts[0] is owner of event
        let payoutAmount = await event.payout()
        assert.equal(payoutAmount, 2000) // 3 out of 6 participants attended for 1000 each hence the 3 of them share 6000wei 
        await truffleAssert.passes(event.withdraw({ from: accounts[5] }))
        await truffleAssert.passes(event.withdraw({ from: accounts[6] }))
        await truffleAssert.passes(event.withdraw({ from: accounts[7] }))
        let eventContractBalance = await event.totalBalance()
        assert.equal(eventContractBalance, 0)
    })
})