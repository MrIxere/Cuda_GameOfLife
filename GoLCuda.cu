#include <cuda_runtime.h>
#include <iostream>
#include <ostream>
#include <vector>
#include <random>


#define CELL_LENGTH 30

__device__
int AliveCount(const char* state, int x, int y)
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

__global__
void Compute(const char* state, char* output)
{
    int x = threadIdx.x % CELL_LENGTH;
    int y = threadIdx.x / CELL_LENGTH;
    
    int nbAlive = AliveCount(state, x, y);
    bool isAlive = state[x + y * CELL_LENGTH] == 1;
    if (isAlive)
    {
        if (isAlive && (nbAlive == 3 || nbAlive == 2))
        {
            output[x + y * CELL_LENGTH] = 1;
        }
        else
        {
            output[x + y * CELL_LENGTH] = 0;
        }
    }
    else
    {
        if (!isAlive && nbAlive == 3)
        {
            output[x + y * CELL_LENGTH] = 1;
        }
        else
        {
            output[x + y * CELL_LENGTH] = 0;
        }
    }
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
    //srand(177013);
    //std::vector<char> State = {};
    //for (int i = 0; i < CELL_LENGTH * CELL_LENGTH; ++i)
    //{
    //    char randValue = (rand() % 2);
    //    State.push_back(randValue);
    //}
    //for (int i = 0; i < 1000; ++i)
    //{
    //    std::cout << "State: " << i << "\n";
    //    std::cout << State;
    //    std::vector<char> newState = Compute(State);
    //    State = newState;
    //    _sleep(10);
    //    std::cout << "\033[H";
    //    //system("cls");
    //	srand(177013);



    //cudification du code


    char* d_A;
    cudaMalloc(&d_A, CELL_LENGTH * CELL_LENGTH);

    char* d_outputPtr;
    cudaMalloc(&d_outputPtr, CELL_LENGTH * CELL_LENGTH);

    char* h_outputPtr = static_cast<char*>(calloc(CELL_LENGTH * CELL_LENGTH, 1));

    srand(177013);
    std::vector<char> State = {};
    for (int i = 0; i < CELL_LENGTH * CELL_LENGTH; ++i)
    {
        char randValue = (rand() % 2);
        State.push_back(randValue);
    }
    for (int i = 0; i < 1000; ++i)
    {
        std::cout << State;
    	std::cout << "State: " << i;
        
        cudaMemcpy(d_A, State.data(), CELL_LENGTH * CELL_LENGTH, cudaMemcpyHostToDevice);
        Compute << <1, CELL_LENGTH* CELL_LENGTH >> > (d_A, d_outputPtr);
        cudaMemcpy(h_outputPtr, d_outputPtr, State.size(), cudaMemcpyDeviceToHost);
        for (int i = 0; i < CELL_LENGTH * CELL_LENGTH; ++i)
        {
            State[i] = h_outputPtr[i];
        }
        _sleep(10);
        std::cout << "\033[H";
        //system("cls");
    }
    cudaFree(d_A);
    cudaFree(d_outputPtr);
    free(h_outputPtr);
    return 0;
}