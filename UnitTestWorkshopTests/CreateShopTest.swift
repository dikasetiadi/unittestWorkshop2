//
//  CreateShopTest.swift
//  TokopediAloneTests
//
//  Created by Bondan Eko Prasetyo on 15/07/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import Quick
import XCTest
import RxCocoa

@testable import UnitTestWorkshop

private class CreateShopTest: CreateShopViewModelBaseTest {
    override func spec() {
        let useCase = CreateShopUsecase()
        
        beforeEach {
            self.setupBinding(viewModel: CreateShopViewModel(useCase: useCase))
        }
        
        describe("Register new shop") {
            
            // MARK: Typing Shop Name Test Case
            context("Typing Shop Name that not available") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(false)
                    }
                }
                
                it("Invalid Shopname, still generate the domain name") {
                    self.shopNameSubject.onNext("supergadgettt")
                    self.domainNameValue.assertValue("supergadgettt-4")
                    self.shopNameError.assertValue(ShopError.notAvailable.message)
                    self.shopNameErrorIsHidden.assertLastValue(false)
                }
            }
            
            context("Typing Shop Name that available") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                        .just(true)
                    }
                }
                
                it("Valid Shopname, will generate domain name suggestion") {
                    self.shopNameSubject.onNext("asdf")
                    self.domainNameValue.assertValue("asdf-4")
                    self.shopNameError.assertDidNotEmitValue()
                    self.shopNameErrorIsHidden.assertLastValue(true)
                }
                
                it("Show Error when shop name has less than 3 characters") {
                    self.shopNameSubject.onNext("as")
                    self.shopNameValue.assertValue("as")
                    self.shopNameError.assertValue(ShopError.minCharacter.message)
                    self.shopNameErrorIsHidden.assertLastValue(false)
                }
                
                it("Show Error when shop name start ort end with spacing") {
                    self.shopNameSubject.onNext(" asd")
                    self.shopNameValue.assertValue(" asd")
                    self.shopNameError.assertValue(ShopError.startOrEndWithWhitespace.message)
                    self.shopNameErrorIsHidden.assertLastValue(false)
                }
                
                it("Show Error when shop name contain emoji") {
                    self.shopNameSubject.onNext("as😄d")
                    self.shopNameValue.assertValue("as😄d")
                    self.shopNameError.assertValue(ShopError.containEmoji.message)
                    self.shopNameErrorIsHidden.assertLastValue(false)
                }
                
                it("Show Error when shop name empty") {
                    self.shopNameSubject.onNext("")
                    self.shopNameValue.assertValue("")
                    self.shopNameError.assertValue(ShopError.textEmpty.message)
                    self.shopNameErrorIsHidden.assertLastValue(false)
                }
            }
            
            // MARK: Typing Domain Name Test Case
            context("Typing Domain Name valid") {
                it("Domain Name Valid") {
                    self.domainNameSubject.onNext("asdf-4")
                    self.domainNameValue.assertValue("asdf-4")
                    self.domainNameError.assertValue(nil)
                    self.domainErrorIsHidden.assertLastValue(true)
                }
            }
            
            context("Typing Domain Name not valid") {
                beforeEach {
                    useCase.checkDomainNameAvailability = { _ in
                        .just("Domain Name is not valid, please change the domain name")
                    }
                }
                
                it("Domain Name not Valid") {
                    self.domainNameSubject.onNext("notValidDomain")
                    self.domainNameValue.assertValue("notValidDomain")
                    self.domainNameError.assertValue("Domain Name is not valid, please change the domain name")
                    self.domainErrorIsHidden.assertLastValue(false)
                }
            }
            
            context("Typing Domain Name is less than 3 character") {
                beforeEach {
                    useCase.checkDomainNameAvailability = { _ in
                        .just(ShopError.minCharacter.message)
                    }
                }
                
                it("Show Error when domain name has less than 3 characters") {
                    self.domainNameSubject.onNext("as")
                    self.domainNameValue.assertValue("as")
                    self.domainNameError.assertValue(ShopError.minCharacter.message)
                    self.domainErrorIsHidden.assertLastValue(false)
                }
                
                it("hide Error when user typing again new domain") {
                    self.domainNameSubject.onNext("as")
                    self.domainNameValue.assertValue("as")
                    self.domainNameError.assertValue(ShopError.minCharacter.message)
                    self.domainErrorIsHidden.assertLastValue(false)
                    
                    useCase.checkDomainNameAvailability = { _ in
                        .just(nil)
                    }
                    
                    self.domainNameSubject.onNext("newShop")
                    self.domainNameValue.assertLastValue("newShop")
                    self.domainNameError.assertLastValue(nil)
                    self.domainErrorIsHidden.assertLastValue(true)
                }
            }
            
            // MARK: Select City Test Case
            context("Select City") {
                it("Show Selected City") {
                    let selectionCity = City(id: "2", name: "Jakarta")
                    
                    self.inputCitySubject.onNext(selectionCity)
                    self.city.assertValue(selectionCity)
                }
                
                it("Close the Select City Screen should show error when city is not selected") {
                    self.inputCitySubject.onNext(nil)
                    self.cityError.assertValue(ShopError.textEmpty.message)
                }
                
                it("Close the Select City Screen does not show error when city is already selected") {
                    let selectionCity = City(id: "2", name: "Jakarta")
                    
                    // first we select
                    self.inputCitySubject.onNext(selectionCity)
                    // and after that we click again select city & cancel it
                    self.inputCitySubject.onNext(nil)
                    // make sure city has last selection from user
                    self.city.assertLastValue(selectionCity)
                }
            }
            
            // MARK: Select postal code
            context("Select Postal Code") {
                it("Show Error City is Required, when click postal code without select the citty first") {
                    self.postalCodeSubject.onNext(())
                    self.cityError.assertValue(ShopError.textEmpty.message)
                }
                
                it("Select Postal code after the city is selected") {
                    let newSelectedCity = City(id: "2", name: "Jakarta")
                    
                    // select city
                    self.inputCitySubject.onNext(newSelectedCity)
                    self.city.assertValue(newSelectedCity)
                    
                    // open postal page
                    self.postalCodeSubject.onNext(())
                    
                    // select postal code
                    self.postalCodeValueSubject.onNext("4441")
                    self.postalCode.assertValue("4441")
                    
                    // expect no error (selected)
                    self.postalErrorIsHidden.assertLastValue(true)
                }
                
                it("Should reset postal code after select a new city"){
                    // last value city
                    let currentSelectedCity = City(id: "2", name: "Jakarta")
                    self.inputCitySubject.onNext(currentSelectedCity)
                    self.city.assertValue(currentSelectedCity)
                    
                    // insert last value postal
                    self.postalCodeValueSubject.onNext("1234")
                    
                    // new value city
                    let newSelectedCity = City(id: "1", name: "Bekasi")
                    self.inputCitySubject.onNext(newSelectedCity)
                    
                    // reset postal value to empty & expect no error is show
                    self.postalCodeValueSubject.onNext(nil)
                    self.postalErrorIsHidden.assertLastValue(true)
                }
            }
        }
    }
}

