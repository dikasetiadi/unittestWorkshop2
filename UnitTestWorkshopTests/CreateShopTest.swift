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
            context("Typing shop name and shop name valid") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(true)
                    }
                    self.shopNameSubject.onNext("asdf")
                }

                it("should dsiplay shop name") {
                    self.shopNameValue.assertValue("asdf")
                }

                it("should not show error shop name") {
                    self.shopNameError.assertDidNotEmitValue()
                    // expected 3 times because
                    // 1 value emit from process VM
                    // 1 value emit from use case mock
                    self.shopNameErrorIsHidden.assertValues([true, true, true])
                }

                it("should generate domain name") {
                    self.domainNameValue.assertValue("asdf-4")
                }
            }

            context("typing invalid shop name") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(false)
                    }
                    self.shopNameSubject.onNext("supergadgettt")
                }

                it("should display shop name") {
                    self.shopNameValue.assertValue("supergadgettt")
                }

                it("should display error invalid shop name") {
                    self.shopNameError.assertValue(ShopError.notAvailable.message)
                    self.shopNameErrorIsHidden.assertValues([true, true, false])
                }

                it("should generate domain name") {
                    self.domainNameValue.assertValue("supergadgettt-4")
                }
            }

            context("Typing shop name less than 3 character") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(true)
                    }
                    self.shopNameSubject.onNext("as")
                }

                it("should display shop name") {
                    self.shopNameValue.assertValue("as")
                }

                it("should display error shop minimal character") {
                    self.shopNameError.assertValue(ShopError.minCharacter.message)
                    self.shopNameErrorIsHidden.assertValues([true, false])
                }

                it("should generate domain name") {
                    self.domainNameValue.assertValue("as-4")
                }
            }

            context("typing shop name with start or end using space") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(true)
                    }
                    self.shopNameSubject.onNext("shop ")
                }

                it("should diplay shop name") {
                    self.shopNameValue.assertValue("shop ")
                }

                it("should display error shop name contain space on it's start or end") {
                    self.shopNameError.assertValue(ShopError.startOrEndWithWhitespace.message)
                    self.shopNameErrorIsHidden.assertValues([true, false])
                }

                it("should display domain name") {
                    self.domainNameValue.assertValue("shop -4")
                }
            }

            context("typing shop name with emoji") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(true)
                    }
                    self.shopNameSubject.onNext("as😄d")
                }

                it("should display shop name") {
                    self.shopNameValue.assertValue("as😄d")
                }

                it("should display error shop name contains emoji") {
                    self.shopNameError.assertValue(ShopError.containEmoji.message)
                    self.shopNameErrorIsHidden.assertValues([true, false])
                }

                it("should display domain name") {
                    self.domainNameValue.assertValue("as😄d-4")
                }
            }

            context("user delete all shop name") {
                beforeEach {
                    useCase.checkShopNameAvailability = { _ in
                       .just(true)
                    }
                    self.shopNameSubject.onNext("")
                }

                it("should display empty shop name") {
                    self.shopNameValue.assertValue("")
                }

                it("should display error shop name was empty") {
                    self.shopNameError.assertValue(ShopError.textEmpty.message)
                    self.shopNameErrorIsHidden.assertValues([true, false])
                }

                it("should display domain name") {
                    self.domainNameValue.assertValue("-4")
                }
            }

            // MARK: Typing Domain Name Test Case
            context("user typing valid domain name") {
                beforeEach {
                    self.domainNameSubject.onNext("BermainBersama")
                }

                it("should display domain name") {
                    self.domainNameValue.assertValue("BermainBersama")
                }

                it("should not show error domain name not valid") {
                    self.domainNameError.assertValue(nil)
                    // because only emit 1 value,
                    // user assertValue only
                    self.domainErrorIsHidden.assertValue(true)
                }
            }

            context("user typing not valid domain name") {
                beforeEach {
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(ShopError.notValidDomain.message)
                    }
                    self.domainNameSubject.onNext("tokopedia")
                }

                it("should display domain name") {
                    self.domainNameValue.assertValue("tokopedia")
                }

                it("should show error not valid domain name") {
                    self.domainNameError.assertValue(ShopError.notValidDomain.message)
                    self.domainErrorIsHidden.assertValue(false)
                }
            }

            context("user typing domain name less than 3 characters") {
                beforeEach {
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(ShopError.minCharacter.message)
                    }
                    self.domainNameSubject.onNext("to")
                }

                it("should display domain name") {
                    self.domainNameValue.assertValue("to")
                }

                it("should show error minimal 3 character on domain name") {
                    self.domainNameError.assertValue(ShopError.minCharacter.message)
                    self.domainErrorIsHidden.assertValue(false)
                }
            }

            context("user typing invalid domain and re-typing new valid domain shop") {
                beforeEach {
                    // we set scenario of user get invalid domain
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(ShopError.notValidDomain.message)
                    }
                    self.domainNameSubject.onNext("tokopedia")

                    // here we set scenario user re-typing with valid domain
                    useCase.checkDomainNameAvailability = { _ in
                        return .just(nil)
                    }
                    self.domainNameSubject.onNext("bermainBersama")
                }

                it("should display domain name") {
                    self.domainNameValue.assertValues(["tokopedia", "bermainBersama"])
                }

                it("should display error invalid domain and hide after re-typing new valid domain") {
                    self.domainNameError.assertValues([ShopError.notValidDomain.message, nil])
                    self.domainErrorIsHidden.assertValues([false, true])
                }
            }

            // MARK: Select City Test Case
            context("user select the city") {
                beforeEach {
                    self.inputCitySubject.onNext(.jakarta)
                }

                it("show selected city name") {
                    self.city.assertValue(.jakarta)
                }
            }

            context("show error when user close select city page without select the city") {
                beforeEach {
                    // set selected city to nil
                    self.inputCitySubject.onNext(nil)
                }

                it("should show error city is should not empty") {
                    self.cityError.assertValue(ShopError.textEmpty.message)
                }
            }

            context("dont show error when user close select city option when user already choose selected city") {
                beforeEach {
                    self.inputCitySubject.onNext(.jakarta)

                    // nil means user click batal button to close select city page
                    self.inputCitySubject.onNext(nil)
                }

                it("city value should has last value") {
                    self.city.assertValues([.jakarta])
                }
            }

            // MARK: Select postal code
            context("show error when user select postal and user still not select the city") {
                beforeEach {
                    self.inputCitySubject.onNext(nil)

                    // means we click the postal code button to open
                    self.postalCodeSubject.onNext(())
                }

                it("should show error city is required") {
                    self.cityError.assertLastValue(ShopError.textEmpty.message)
                }
            }

            context("user select postal code after select the city first") {
                beforeEach {
                    self.inputCitySubject.onNext(.jakarta)
                    self.postalCodeValueSubject.onNext("4444")
                }

                it("should show selected city") {
                    self.city.assertValue(.jakarta)
                }

                it("should show selected postal code") {
                    self.postalCode.assertValue("4444")
                }

                it("should not show error city is required to select") {
                    self.cityError.assertDidNotEmitValue()
                    self.cityErrorIsHidden.assertDidNotEmitValue()
                }
            }

            context("user select new city after set the city and the postal") {
                beforeEach {
                    self.inputCitySubject.onNext(.jakarta)
                    self.postalCodeValueSubject.onNext("4444")

                    self.inputCitySubject.onNext(.bekasi)
                }

                it("should show latest city selected") {
                    self.city.assertValues([.jakarta, .bekasi])
                }

                it("should clear value postal") {
                    // if value === Postal Code string means its reset to nil value
                    // get this logic from VM code
                    self.postalCode.assertLastValue("Postal Code")
                }
            }
        }
    }
}

