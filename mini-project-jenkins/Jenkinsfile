pipeline {
	environment {
		APP_NAME = "elie"
		ID_DOCKER = "dockerd452"
		IMAGE_NAME = "staticwebsite"
		IMAGE_TAG = "latest"
		PORT_EXPOSED = "8081"
		INTERNAL_PORT = "5000"
		STG_API_ENDPOINT = "192.168.56.10:1993"
		STG_APP_ENDPOINT = "192.168.56.10:8081"
       	CONTAINER_IMAGE = "${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}"
	}
	agent none
	stages {
		stage('BUILD image') {
			agent any
			steps {
				script {
					sh 'docker build -t $ID_DOCKER/$IMAGE_NAME:$IMAGE_TAG .'
				}
			}
		}
		stage('RUN container based on builded image') {
			agent any
			steps {
				script {
					sh '''
						docker run --name $IMAGE_NAME -d -p $PORT_EXPOSED:$INTERNAL_PORT -e PORT=$INTERNAL_PORT $ID_DOCKER/$IMAGE_NAME:$IMAGE_TAG
						sleep 5
					'''
				}
			}
		}
		stage('TEST image') {
			agent any
			steps {
				script {
					sh '''
						curl http://172.17.0.1 | grep -i "dimension"
					'''
				}
			}
		}
		stage('Clean Container') {
			agent any
			steps {
				script {
					sh '''
						docker stop ${IMAGE_NAME}

						docker rm ${IMAGE_NAME}
					'''
				}
			}
		}

		stage ('Login and Push Image on docker hub') {
          agent any
        	environment {
           		DOCKERHUB_CREDENTIALS = credentials('docker_dockerd452')
        	}            
          	steps {
            	script {
               		sh '''
                		echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                    	docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               		'''
             	}
          	}
      	}

      	stage('STAGING - Deploy app') {
       		when {
        		expression { GIT_BRANCH == 'origin/jenkins' }
        	}
      		agent any

      		steps {
        		script {
            		sh """
            			echo $APP_NAME
            			echo $CONTAINER_IMAGE
               			curl -X POST http://${STG_API_ENDPOINT}/staging -H 'Content-Type: application/json' -d '{"your_name":"${APP_NAME}","container_image":"${CONTAINER_IMAGE}", "external_port":"${PORT_EXPOSED}", "internal_port":"${INTERNAL_PORT}"}'
               		"""
        		}
        	}
     	}
	}

	post {
       	success {
         	slackSend (color: '#00FF00', message: "ELIE- SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL}) - STAGING URL => http://${STG_APP_ENDPOINT}")
        }
      	failure {
            slackSend (color: '#FF0000', message: "ELIE - FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }   
    } 
}
             
