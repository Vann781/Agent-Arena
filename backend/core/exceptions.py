class DebateNotFoundError(Exception):
    def __init__(self, debate_id: str):
        self.debate_id = debate_id
        super().__init__(f"Debate {debate_id} not found")


class DebateCompletedError(Exception):
    def __init__(self, debate_id: str):
        self.debate_id = debate_id
        super().__init__(f"Debate {debate_id} is already completed")


class VoteAlreadyExistsError(Exception):
    def __init__(self, debate_id: str, session_id: str):
        self.debate_id = debate_id
        self.session_id = session_id
        super().__init__(f"Vote already exists for session {session_id} on debate {debate_id}")
