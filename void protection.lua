-- Variáveis para monitorar o tempo de queda
local fallTimeThreshold = 1 -- tempo em segundos para ativar a flutuação
local isFalling = false
local fallStartTime = 0

-- Função para adicionar BodyVelocity ao personagem para flutuação
local function floatCharacter(character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local bodyVelocity = humanoidRootPart:FindFirstChild("BodyVelocity")
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 7, 0) -- Ajuste a velocidade conforme necessário
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Parent = humanoidRootPart
        else
            bodyVelocity.Velocity = Vector3.new(0, 7, 0) -- Atualize a velocidade, se necessário
        end
    end
end

-- Função para monitorar o estado de queda e ativar a flutuação
local function monitorFalling(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Freefall then
            -- Começou a cair
            if not isFalling then
                isFalling = true
                fallStartTime = tick() -- Marca o tempo de início da queda
            end
        else
            -- Parou de cair
            if isFalling then
                isFalling = false
                fallStartTime = 0
            end
        end
    end)

    -- Checa continuamente se o personagem está caindo por mais de 1 segundo
    while true do
        if isFalling and (tick() - fallStartTime) > fallTimeThreshold then
            -- Ativa a flutuação se o personagem estiver caindo por mais de 1 segundo
            floatCharacter(character)
        end
        wait(0.1) -- Ajuste o intervalo conforme necessário para otimização
    end
end

-- Espera o personagem do jogador estar pronto
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Monitora o estado de queda e ativa a flutuação quando necessário
monitorFalling(character)

-- Garante que a monitorização continue quando o personagem respawnar
player.CharacterAdded:Connect(function(newCharacter)
    monitorFalling(newCharacter)
end)