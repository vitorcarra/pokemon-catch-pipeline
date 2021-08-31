FROM lambci/lambda:build-python3.7



RUN python3.7 -m pip install --upgrade pip && \
    python3.7 -m pip install virtualenv

RUN python3.7 -m venv pandas

COPY requirements.txt requirements.txt

RUN source pandas/bin/activate

RUN pip install -r requirements.txt