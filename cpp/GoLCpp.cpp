#include <iostream>
#include <ostream>
#include <vector>
#include <random>


#define CELL_LENGTH 42

int AliveCount(const std::vector<char>& state, int x, int y)
{
    int aliveCount = 0;
    for (int ix = -1; ix <= 1; ++ix)
    {
        for (int iy = -1; iy <= 1; ++iy)
        {
            if (ix == 0 && iy == 0)
            {
                continue;
            }
            if (ix + x < 0 || (ix + x >= CELL_LENGTH))
            {
                continue;
            }
            if (iy + y < 0 || (iy + y >= CELL_LENGTH))
            {
                continue;
            }
            if (state[(x + ix) + (y + iy) * CELL_LENGTH] == 1)
            {
                aliveCount++;
            }
        }
    }
    return aliveCount;
}

std::vector<char> Compute(const std::vector<char>& state)
{
    std::vector<char> newState = state;
    newState.resize(state.size());
    for (int x = 0; x < CELL_LENGTH; ++x)
    {
        for (int y = 0; y < CELL_LENGTH; ++y)
        {
            int nbAlive = AliveCount(state, x, y);
            bool isAlive = state[x + y * CELL_LENGTH] == 1;
            if (isAlive)
            {
                if (isAlive && (nbAlive == 3 || nbAlive == 2))
                {
                    newState[x + y * CELL_LENGTH] = 1;
                }
                else
                {
                    newState[x + y * CELL_LENGTH] = 0;
                }
            }
            else
            {
                if (!isAlive && nbAlive == 3)
                {
                    newState[x + y * CELL_LENGTH] = 1;
                }
                else
                {
                    newState[x + y * CELL_LENGTH] = 0;
                }
            }

        }
    }
    return newState;
}

std::ostream& operator<<(std::ostream& os, const std::vector<char>& state)
{
    for (int x = 0; x < CELL_LENGTH; ++x)
    {
        for (int y = 0; y < CELL_LENGTH; ++y)
        {
            if (state[x + y * CELL_LENGTH] == 1)
            {
                os << " @ ";
            }
            else
            {
                os << "   ";
            }
        }
        os << std::endl;
    }
    return os;
}

int main()
{
    srand(177013);
    std::vector<char> State = {};
    for (int i = 0; i < CELL_LENGTH * CELL_LENGTH; ++i)
    {
        char randValue = (rand() % 2);
        State.push_back(randValue);
    }
    for (int i = 0; i < 1000; ++i)
    {
        std::cout << "State: " << i << "\n";
        std::cout << State;
        std::vector<char> newState = Compute(State);
        State = newState;
        _sleep(10);
        std::cout << "\033[H";
        //system("cls");
    }

    return 0;
}