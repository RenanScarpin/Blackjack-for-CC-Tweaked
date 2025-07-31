-- Define card values and suits
local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
local values = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

-- Function to create a deck of cards
local function createDeck()
    local deck = {}
    for _, suit in ipairs(suits) do
        for _, value in ipairs(values) do
            table.insert(deck, {value = value, suit = suit})
        end
    end
    return deck
end

-- Function to shuffle the deck
local function shuffleDeck(deck)
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

-- Function to draw a card from the deck
local function drawCard(deck)
    return table.remove(deck, 1)
end

-- Function to calculate the value of a hand
local function calculateHandValue(hand)
    local value = 0
    local aces = 0
    for _, card in ipairs(hand) do
        if card.value == "J" or card.value == "Q" or card.value == "K" then
            value = value + 10
        elseif card.value == "A" then
            value = value + 11
            aces = aces + 1
        else
            value = value + tonumber(card.value)
        end
    end
    while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
    end
    return value
end

-- Function to print a hand
local function printHand(hand, name)
    print(name .. "'s Hand:")
    for _, card in ipairs(hand) do
        print(card.value .. " of " .. card.suit)
    end
    local value = calculateHandValue(hand)
    if(value == 21) then
        print("Blackjack!")
    else
        print("Total Value: " .. value)
    end
    print()
end

local function takeBet(bet)
    print("Insert your bet in my inventory")
    local remaining = bet
    while true do
        for i = 1, 16, 1 do
            turtle.select(i)
            if(turtle.getItemCount() > 0 and turtle.getItemDetail().name == "minecraft:diamond") then
                local count = turtle.getItemCount()
                if(count >= remaining) then
                    turtle.dropDown(remaining)
                    return
                else
                    turtle.dropDown(count)
                    remaining = remaining - count
                end
            end
        end
    end
end

-- Main game function
local function playBlackjack()
    -- Prompt player to enter a bet
    print("Enter your bet amount:")
    local bet = tonumber(io.read())
    if not bet or bet <= 0 then
        print("Invalid bet amount. Please enter a positive integer.")
        return
    end

    takeBet(bet)

    -- Create and shuffle the deck
    local deck = createDeck()
    shuffleDeck(deck)

    -- Deal initial hands
    local playerHand = {drawCard(deck), drawCard(deck)}
    local dealerHand = {drawCard(deck), drawCard(deck)}

    -- Player's turn
    while true do
        printHand(playerHand, "Player")
        if calculateHandValue(playerHand) > 21 then
            print("Player busts! Dealer wins.")
            print("Player's payout: 0")
            return
        end

        if calculateHandValue(playerHand) == 21 then
            break
        end

        print("Do you want to (d)ouble, (h)it or (s)tand?")
        local choice = io.read()
        if choice == "s" then
            break
        elseif choice == "h" then
            table.insert(playerHand, drawCard(deck))
        elseif choice == "d" then
            table.insert(playerHand, drawCard(deck))
            takeBet(bet)
            bet = bet * 2
            break
        else
            print("Invalid choice, please enter 'd', 'h' or 's'.")
        end
    end

    -- Dealer's turn
    while calculateHandValue(dealerHand) < calculateHandValue(playerHand) do
        table.insert(dealerHand, drawCard(deck))
    end

    printHand(playerHand, "Player")
    printHand(dealerHand, "Dealer")

    -- Determine the winner
    local playerValue = calculateHandValue(playerHand)
    local dealerValue = calculateHandValue(dealerHand)

    local payout = 0
    if dealerValue > 21 or playerValue > dealerValue then
        print("Player wins!")
        payout = bet * 2
    elseif dealerValue == playerValue then
        print("It's a tie!")
        payout = bet
    else
        print("Dealer wins!")
    end

    print("Player's payout: " .. payout)
    turtle.suckDown(payout)
end

-- Start the game
math.randomseed()
playBlackjack()
