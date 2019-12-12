node {
    def dockerImg //global var used to store docker img

    stage('Clone repo') {
        checkout scm // Clone repository to workspace
    }
    stage('Analyse code') {
        echo 'Starting static code analysis'
        def scannerHome = tool 'SonarQube'; //Get directory of sonar plugin
        withSonarQubeEnv('SonarQube') { //Choose SonarQube server
            sh "${scannerHome}/bin/sonar-scanner" //Select property file
        }
    }
    stage('Quality Gate') {
        echo 'Check results of SonarQube'
        timeout(time: 15, unit: 'MINUTES') { //Timeout which aborts if a process takes to long
            def qualityGate = waitForQualityGate() //Await SonarQube Scan result

            if (qualityGate.status != 'OK') { //Compare scan result with acceptable result
                error "Pipeline aborted due to quality gate failure: ${qualityGate.status}" //Error and abort if the scan result is not acceptable
            }
        }
    }
    stage('Build img') {
        echo 'Building docker image'
        dockerImg = docker.build("frazzle99/cw2:${env.BUILD_ID}") //Build docker img with unique id
    }
    stage('Publish img') {
        echo 'Publishing image to DockerHub'
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') { //Authenticate with dockerhub
            dockerImg.push(env.BUILD_ID) //Publish built image (specific tag)
            dockerImg.push('latest') //Publish built image (latest)
        }
    }
    stage('Deploy') {
        ansiblePlaybook installation: 'Ansible', playbook: '/playbooks/prod_create.yml'
        ansiblePlaybook(playbook: "${WORKSPACE}/playbooks/prod_create.yml")
        //sh "ansible-playbook ${env.WORKSPACE}/playbooks/prod_create.yml"
        //sh "ansible-playbook -i ~/ansible/azure_rm.py -l cw2prod ${env.WORKSPACE}/playbooks/prod_config.yml"
    }
}