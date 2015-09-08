User: {
	Registration: {
		url: 	localhost:3000/users,
		method: POST,
		paras: {
			"user": {
				"username",			// can be duplicated
				"phone_number"		// Has to be uniq
				"email", 			// Email must follow the format
				"password", 		// Password needs to be at least 8 digits  and  no need for password confirmation
			}
		},
		return: {
			Created: {
				json: {
					user: resource, 
					status: "Created"
				}, 
				status: 201
			},
			Existed: {
				json: {
					status: "Existed"     // Due to duplicated email
				}, 
				status: 202
			},
			Phone Number Existed: {
				json: {
					status: "Phone Number Existed"
				},
				status: 202
			}
		}
	},
	Login: {
		url:	localhost:3000/users/sign_in,
		method:	POST,
		paras: {
			"user": {
				"email", 				// Only email can be used as login, since name may be duplicated.
				"password"
			}
		},
		return: {
			Login Failure: {
				json: {
					status: "Login Failure"
				},
				status: 202
			},
			Login Success: {
				json: {
					user: resource, 
					status: "Login Success"
				}, 
				status: 200
			}
		}
	},
	Logout: {
		url:	localhost:3000/users/sign_out,
		method: DELETE,
		paras: nil,
		return: nil
	},
	Change Password: {		
		url:	localhost:3000/users 	// Notion: This request need to be requested after Login request succeeds
		method:	PATCH,
		paras: {
			"user": {
				"email",
				"password",					// new password
				"current_password"			// old password
			}
		},
		returns: {
			Update Failure: {
				json: {
					status: "Password Update Failure"
				},
				status: 202
			},
			Update Success: {
				json: {
					user: resource, 
					status: "Password Updated"
				},
				status: 201
			}
		}
	}
}