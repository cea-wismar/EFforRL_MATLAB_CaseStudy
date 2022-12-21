# Experimental Frame for RL and DES -- MATLAB/Simulink Case Study

## Documentation
### Overview
Reinforcement Learning (RL) is a method from the field of Machine Learning. It is characterized by two interacting entities referred to as the agent and the environment. The agent influences the environment through actions and the environment responds with state information and reward values. The goal of RL is to learn how an agent should act to achieve a maximum cumulative reward in the long-term. A Discrete Event Simulation Model (DESM) maps the temporal behavior of a dynamic system. The execution of a DESM is done via a simulator. The concept of an Experimental Frame (EF) defines the general structure used to separate the DESM into the dynamic system, called the Model Under Study (MUS), and its application context. This supports the diverse use of a MUS in different experimental contexts. The paper *Integration of Reinforcement Learning and Discrete Event Simulation Using the Concept of Experimental Frame* submitted to the Eurosim Congress'2023 (will be uploaded after publication) explores the generalized integration of discrete event simulation and RL using the concept of EF. The case study introduced in the paper illustrates the approach using MATLAB/Simulink and SimEvents.

This case study consists of a model **Prodline_EF_RL.slx** and a script **trainProdLine.m**. The model contains the MUS **ProdLine** and the components of the Experimental Frame, **Agent**, **Decoder**, **Encoder**, **Reward**, **Acceptor** and **SU Mapping**.

The agent is already pre-trained. All nesessary variables and parameters are saved in the model workspace. To analyze the training process with different settings of hyperparameters, the agent can be trained again by the **trainProdLine** m-Script.

### Simulink Model
The Simulink model contains all variables and parameters to run a training episode. All values are assigned to the structures **EpisodeData**, which contains all variables that might change during training and **SimOptions**, which contains all values that are constant over all episodes. Both structures are located in the model workspace.

The whole simulation is event driven. To maintain a consistent and reasonable "flow" of information, each block consists of a message input port to start its execution and a output port to signalize its done processing. This ensures every block reads valid data from its predecessor.

######  When the acceptor sets *isDone* to true, the agent will overwrite the *EpisodeData* structure in the matlab workspace with the current *EpisodeData* of the model!

### Training Script
All hyperparameters regarding the learning process are defined at the beginning of the **trainProdLine** script.  They are used to initialize the already introduced structures and define how many episodes the agent shall be trained.
