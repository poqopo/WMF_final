import React, { Component } from 'react'


class Main extends Component {
  render() {
    return (
      <div id="content" className="mt-3">
        {this.props.pendingWMF}

        <table className="table table-borderless text-muted text-center">
          <thead>
            <tr>
              <th scope="col">MockDai Balance</th>
              <th scope="col">WUSD Balance</th>
              <th scope="col">WMF Balance</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              {/* <td>{window.web3.utils.fromWei(this.props.WUSDTokenBalance, 'WUSD')} WUSD</td>
              <td>{window.web3.utils.fromWei(this.props.WMFTokenBalance, 'WMF')} DAPP</td> */}
              <td>{window.web3.utils.fromWei(this.props.MockDaiTokenBalance, 'Ether')} MockDai</td>
              <td>{window.web3.utils.fromWei(this.props.WUSDTokenBalance, 'Ether')} WUSD</td>
              <td>{window.web3.utils.fromWei(this.props.WMFTokenBalance, 'Ether')} WMF</td>
            </tr>
          </tbody>
        </table>

        <div className="card mb-4" >

          <div className="card-body">

            <form className="mb-3" onSubmit={(event) => {
                event.preventDefault()
                let amount
                amount = this.input.value.toString()
                amount = window.web3.utils.toWei(amount, 'Ether')
                this.props.mintAlgorithmicWUSD(amount)
              }}>
              <div>
                <label className="float-left"><b>Stake Tokens</b></label>
                <span className="float-right text-muted">
                  Balance: {window.web3.utils.fromWei(this.props.WUSDTokenBalance, 'Ether')}
                </span>
              </div>
              <div className="input-group mb-4">
                <input
                  type="text"
                  ref={(input) => { this.input = input }}
                  className="form-control form-control-lg"
                  placeholder="0"
                  required />
                <div className="input-group-append">
                  <div className="input-group-text">
                  
                    &nbsp;&nbsp;&nbsp; mDAI
                  </div>
                </div>
              </div>
              <button type="submit" className="btn btn-primary btn-block btn-lg">STAKE!</button>
            </form>
            <button
              type="submit"
              className="btn btn-link btn-block btn-sm"
              onClick={(event) => {
                event.preventDefault()
                this.props.unstakeTokens()
              }}>
                UN-STAKE...
              </button>
              <div style={{height:100}}></div>
              <button
                disabled={this.props.collateralRatio < 10000}
                onClick={event => {
                  event.preventDefault()
                  this.props.testFunc()
                }}
              >
                TEST
              </button>
              <div style={{height:100}}></div>
              <button
                onClick={event => {
                  event.preventDefault()
                  this.props.mintFractionalWUSD(window.web3.utils.toWei('90', 'Ether'), window.web3.utils.toWei('100', 'Ether'), window.web3.utils.toWei('1', 'Ether'))
                }}
              >
                TEST
              </button>
          </div>
        </div>

      </div>
    );
  }
}

export default Main;