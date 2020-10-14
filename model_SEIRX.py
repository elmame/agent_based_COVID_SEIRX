import numpy as np
from mesa import Model
from mesa.time import RandomActivation, SimultaneousActivation
from mesa.datacollection import DataCollector

from agent_patient import Patient
from agent_employee import Employee
from testing_strategy import Testing

def count_E_patient(model):
    E = np.asarray([a.exposed for a in model.schedule.agents if a.type == 'patient']).sum()
    return E
def count_I_patient(model):
    I = np.asarray([a.infected for a in model.schedule.agents if a.type == 'patient']).sum()
    return I
def count_R_patient(model):
    R = np.asarray([a.recovered for a in model.schedule.agents if a.type == 'patient']).sum()
    return R
def count_X_patient(model):
    X = np.asarray([a.quarantined for a in model.schedule.agents if a.type == 'patient']).sum()
    return X
def count_T_patient(model):
    T = np.asarray([a.testable for a in model.schedule.agents if a.type == 'patient']).sum()
    return T
def count_E_employee(model):
    E = np.asarray([a.exposed for a in model.schedule.agents if a.type == 'employee']).sum()
    return E
def count_I_employee(model):
    I = np.asarray([a.infected for a in model.schedule.agents if a.type == 'employee']).sum()
    return I
def count_R_employee(model):
    R = np.asarray([a.recovered for a in model.schedule.agents if a.type == 'employee']).sum()
    return R
def count_X_employee(model):
    X = np.asarray([a.quarantined for a in model.schedule.agents if a.type == 'employee']).sum()
    return X
def count_T_employee(model):
    T = np.asarray([a.testable for a in model.schedule.agents if a.type == 'employee']).sum()
    return T
def get_infection_state(agent):
    if agent.exposed == True: return 'exposed'
    elif agent.infected == True: return 'infected'
    elif agent.recovered == True: return 'recovered'
    else: return 'susceptible'
def get_quarantine_state(agent):
    if agent.quarantined == True: return True
    else: return False

class SIR(Model):
    '''
    A model with a number of patients that reproduces the SEIR dynamics
    G: interaction graph between agents
    verbosity: verbosity level [0, 1, 2]
    '''
    def __init__(self, G, N_employees, verbosity, seed):
        self.verbosity = verbosity
        self.Nstep = 0 # internal step counter used to launch screening tests

        ## durations
        #  NOTE: all durations are inclusive, i.e. comparison are "<=" and ">="
        self.infection_duration = 12 # number of days agents stay infectuous
        self.exposure_duration = 5 # days after transmission until agent becomes infectuous
        self.time_until_symptoms = 2 # days after becoming infectuous until becoming testable
        self.time_testable = 10 # days after becoming infectuous while still testable
        self.quarantine_duration = 10 # duration of quarantine
        self.time_until_test_result = 2
        
        # infection risk
        self.transmission_risk_patient_patient = 0.01 # per infected per day
        self.transmission_risk_employee_patient = 0.01 # per infected per day
        self.transmission_risk_employee_employee = 0.01 # per infected per day1
        self.transmission_risk_patient_employee = 0.01 # not used so far

        # index case probability
        self.index_probability = 0.01 # for every employee in every step

        # symptom probability
        self.symptom_probability = 0.5

        # testing strategy
        self.testing_interval = 3 # days
        self.Testing = Testing(self, self.testing_interval,
                     self.verbosity)

        ## agents and their interactions
        self.G = G # interaction graph of patients
        IDs = list(G.nodes)
        #IDs = [i+1 for i in range(len(G.nodes))]
        self.num_agents = len(IDs) + N_employees
        self.num_patients = len(IDs)
        self.num_employees = N_employees

        # add patient and employee agents to the scheduler
        self.schedule = SimultaneousActivation(self)
        for ID in IDs:
            p = Patient(ID, self, verbosity)
            self.schedule.add(p)

        for i in range(1, N_employees + 1):
            e = Employee(i, self, verbosity)
            self.schedule.add(e)
        
        # data collectors to save population counts and patient / employee
        # states every time step
        self.datacollector = DataCollector(
            model_reporters = {'E_patient':count_E_patient,
                               'I_patient':count_I_patient,
                               'R_patient':count_R_patient,
                               'X_patient':count_X_patient,
                               'T_patient':count_T_patient,
                               'E_employee':count_E_employee,
                               'I_employee':count_I_employee,
                               'R_employee':count_R_employee,
                               'X_employee':count_X_employee,
                               'T_employee':count_T_employee},
            agent_reporters = {'infection_state':get_infection_state,
                               'quarantine_state':get_quarantine_state})
        
    def step(self):
        self.datacollector.collect(self)
        self.schedule.step()
        # find symptomatic agents that have not been tested yet
        symptomatic_agents = np.asarray([a for a in self.schedule.agents \
            if (a.symptoms == True and a.test_positive == False)])
        for a in symptomatic_agents:
            # right now, the time between being infected and being potentially
            # symptomatic and the time between being infected and being testable
            # is the same. But since this can potentially change in the future,
            # we only set test_positive = True if the agent is testable at the
            # time of testing
            if a.testable:
                if self.verbosity > 0:
                    print('tested {} {}'.format(a.type, a.ID))
                a.test_positive = True

        # if there is a test-positive agent (i.e. an agent in quarantine),
        # launch a test-screen
        quarantined_agents = np.asarray([a for a in self.schedule.agents \
            if a.quarantined == True])
        if self.verbosity > 0:
            print('{} agents in quarantine'.format(len(quarantined_agents)))
        if len(quarantined_agents) > 0:
            # screen employees
            employees_to_screen = [a for a in self.schedule.agents if \
                (a.type == 'employee' and a.quarantined == False)]
            if self.verbosity > 0: print('initiating employee screen')
            for a in employees_to_screen:
                if a.testable:
                    if self.verbosity > 0:
                        print('tested employee {}'.format(a.ID))
                    a.test_positive = True

            # screen patients
            patients_to_screen = [a for a in self.schedule.agents if \
                (a.type == 'patient' and a.quarantined == False)]
            if self.verbosity > 0: print('initiating patient screen')
            for a in patients_to_screen:
                if a.testable:
                    if self.verbosity > 0:
                        print('tested patient {}'.format(a.ID))
                    a.test_positive = True

        # launches an employee screen every testing_interval step
        #if self.Nstep % self.testing_interval == 0:
        #    cases = self.Testing.screen('employee')
            # if infected employees are detected, an patient screen is launched
        #    if cases > 0:
        #        _ = self.Testing.screen('patient')

        self.Nstep += 1